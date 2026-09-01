# Make coding more python3-ish, this is required for contributions to Ansible
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import csv
import sys
from datetime import datetime
from requests import HTTPError
import os

from ansible.plugins.callback import CallbackBase
from ansible.release import __version__ as ansible__version__

import time
import json
import base64
import subprocess
import re
import requests


TEAM_MOMENT_KEY="metric_delivery_stage"
DELIVERY_STAGE_PLACEHOLDER="no_value_delivery_stage"
WAIT_VERSION_PROCESSUS_TIMOUT=10
WAIT_VERSION_PROCESSUS_ANSIBLE_GALAXY=10
ANSIBLE_GALAXY_VERSION_REGEX="^{collection}\s*(?P<version>\S*)\s*$"
MAX_SEARCH_INVENTORY=10

__version__ = "5.0.0"

class Node:
    """
    Class for the data structure Node
    A node contains all the informations about the current rôle
    A node contains it's node dependencies
    """
    def __init__(self, name: str, parent=None, role_version=None, role_os=None, collection_name=None, collection_version=None):
      self.name = name
      self.childs = []
      self.parent = parent
      self.role_version = role_version
      self.role_os = role_os
      self.collection_name = collection_name
      self.collection_version = collection_version

    def is_child(self, child_name: str, child_os: str) -> bool:
      for child in self.childs:
        if child.name == child_name and child.role_os == child_os:
          return True
      return False

    def get_child(self, child_name: str, child_os: str):
      for child in self.childs:
        if child.name == child_name and child.role_os == child_os:
          return child

    def add_child(self, node):
      self.childs.append(node)

class PlaybookMetadata:
  """
  All the playbook metadata
  """
  def __init__(self, development_stage=None, ansible_version=None, date_now=None):
    self.development_stage = development_stage
    self.ansible_version = ansible_version
    self.date_now = date_now


class Writer:
  """
  Super class for the output
  """
  def write(self, metadata:PlaybookMetadata, node: Node):
    raise NotImplementedError(self.__class__.__name__ + ' not implemented')


class AnsibleWriter(Writer):
  """
  Class for the ansible console output
  it diplays the node in a tree format
  """
  def __init__(self, ansible_display):
    self.ansible_display = ansible_display

  def write(self, metadata:PlaybookMetadata, node: Node, depth=0):

    display = "| " * depth + "|-"+ node.name
    if node.role_version:
      display += ":" + str(node.role_version)

    if node.role_os:
      display +=" (" + node.role_os + ")"

    self.ansible_display.display(display)

    for child in node.childs:
      self.write(metadata, child, depth + 1)


class FileWriter(Writer):
  """
  Class for the file output
  it diplays the node in dict format 
  """
  def __init__(self, ansible_display):
    self.ansible_display = ansible_display


  def _create_document(self, metadata, data):
    #############################
    # Create file in json format#
    #############################

    if not os.path.exists("cartography"):
      os.makedirs("cartography")

    document_name = "cartography/" + str(data["content"]["role_name"]) + "_" + str(data["content"]["collection_name"]) + ".json"
    with open(document_name, 'w') as output_file:
      json.dump(data, output_file)


  def write(self, metadata:PlaybookMetadata, node: Node):
    ##########################################################
    # Build json object with role and collection informations#
    ##########################################################

    for child in node.childs:
      data = {}
      data["content"] = {"role_name": child.name,
                          "role_version": str(child.role_version),
                          "role_os": child.role_os,
                          "collection_name": str(child.collection_name),
                          "collection_version": str(child.collection_version),
                          "role_parent": node.name,
                          "collection_parent": str(node.collection_name)}

      self._create_document(metadata, data)
      self.write(metadata, child)


class CallbackModule(CallbackBase):
    """
    This callback module tells you how long your plays ran for.
    """
    CALLBACK_VERSION = 5.0
    CALLBACK_TYPE = 'aggregate'
    CALLBACK_NAME = 'dependency'

    # only needed if you ship it and don't want enable by default
    CALLBACK_NEEDS_ENABLED = True


    def __init__(self):

      # make sure the expected objects are present, calling the base's __init__
      super(CallbackModule, self).__init__()
      self.root = None
      self.metadata = PlaybookMetadata()


    def v2_playbook_on_start(self, playbook):
      if not self.root:
        self.root = Node(playbook._file_name)
      self._display.v("playbook name:" + playbook._file_name)
      self._display.display("\033[1;32mThe dependency plugin has been succesfully imported!\033[0m")


    def v2_playbook_on_play_start(self, play):
      self.metadata.development_stage = self.get_variable_from_inventory(play.get_variable_manager(), self.metadata.development_stage, TEAM_MOMENT_KEY, DELIVERY_STAGE_PLACEHOLDER)

      self._display.v("development_stage: " + self.metadata.development_stage)
      self._display.v("date: " + str(self.metadata.date_now))

      if not self.root:
        self.root = Node("Service")
    

    def v2_playbook_on_stats(self, stats):

      self._display.display("plugin version: " + __version__)

      self._display.display("")
    
      AnsibleWriter(self._display).write(self.metadata, self.root)
      
      self._display.debug("Création de l'arborescence des roles effectuée")

      FileWriter(self._display).write(self.metadata, self.root)

      self._display.display("")


    def v2_playbook_on_task_start(self, task, is_conditional):
      if task and task._role and task._parent and task._parent._dep_chain:
        hostvars = task.get_variable_manager().get_vars().get("hostvars", {})
        for host, host_data in hostvars.items():
          facts = host_data.get('ansible_facts', {})
          distribution = facts.get("distribution")
          distribution_version = facts.get("distribution_version")
          if not distribution or not distribution_version:
            # Certains plays s'exécutent avant le gather_facts de tous les hôtes.
            # On ignore ces hôtes pour éviter le warning callback: 'distribution'.
            continue
          node = self.root
          for dependency in task._parent._dep_chain:
            task_os = distribution + " " + distribution_version
            if node.is_child(dependency._role_name, task_os):
              node = node.get_child(dependency._role_name, task_os)
            else:
              collection_version = self.get_collection_version(dependency._role_collection)
              node_temp = Node(name=dependency._role_name, 
                              parent=node, 
                              role_os=task_os,
                              collection_name=dependency._role_collection,
                              collection_version=collection_version,
                              role_version=self.get_role_version_from_metadata(dependency))
              node.add_child(node_temp)
              node = node_temp
    

    def get_variable_from_inventory(self, variable_manager, actual_value, metric_name, default_value):
      "Function to get a data from hostvars, it returns the actual_value of the variable if it is neither none, nor the default value"
      if actual_value and actual_value != default_value:
        return actual_value
      hostsKey = list(variable_manager.get_vars()["hostvars"].keys())
      for index in range(min(MAX_SEARCH_INVENTORY, len(hostsKey))):
        host_variables = variable_manager.get_vars()["hostvars"][hostsKey[index]]
        if metric_name in host_variables:
          return host_variables[metric_name]
      return default_value


    def get_role_version_from_metadata(self, role):
        if role._metadata.galaxy_info and 'version' in role._metadata.galaxy_info:
            role_v = str(role._metadata.galaxy_info['version'])
        else:
            role_v = None
        return role_v


    def get_collection_version(self, collection):
        """
        Function to get a collection version from it's name
        """
        # Guard
        if collection == None:
          return None

        # Verify if the ansible-galaxy command seems to exist by getting it's version
        proc_version = subprocess.Popen(['ansible-galaxy', '--version'], stdout=subprocess.DEVNULL)
        proc_version.wait(WAIT_VERSION_PROCESSUS_TIMOUT)
        if proc_version.returncode != 0:
          return None

        # launch the command "ansible-galaxy collection list | grep ""
        proc_ansible_galaxy = subprocess.Popen(['ansible-galaxy', 'collection', 'list'], stdout=subprocess.PIPE)
        proc_grep = subprocess.Popen(['grep', collection], stdin=proc_ansible_galaxy.stdout,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        try:
          proc_grep.wait(WAIT_VERSION_PROCESSUS_ANSIBLE_GALAXY)
          if proc_grep.returncode != 0:
            return None
        except subprocess.TimeoutExpired:
          self._display.warning("There is a timeout when trying to get the version of the collection {collection}".format(collection=collection))
          return None
        # Get the command output
        collection_string = proc_grep.stdout.read().decode('ascii')

        # Get the version from the output
        version_regex = re.search(ANSIBLE_GALAXY_VERSION_REGEX.format(collection=collection), collection_string)
        return version_regex.group("version")
