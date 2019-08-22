// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'tree_list_item.dart';

class ExtensionReorderList extends StatefulWidget {

  final List<TreeNode> objectTree;

  final Widget Function(TreeNode) buildOpenedNode;
  final Widget Function(TreeNode) buildClosedNode;
  final Widget Function() buildLoadingNode;
  final Widget Function(TreeNode) buildNode;
  final Function(TreeNode) onItemTap;
  final Function(TreeNode) loadChildren;
  final Function(TreeNode form, TreeNode to) onMoveNode;

  final double indentation;

  ExtensionReorderList(this.objectTree, {Key key, this.onMoveNode, this.indentation = 30, this.buildClosedNode, this.buildNode, this.buildOpenedNode, this.buildLoadingNode, this.onItemTap, this.loadChildren})
      : super(key: key);
  @override
  _ExtensionReorderListState createState() {
    return _ExtensionReorderListState();
  }

}

class _ExtensionReorderListState extends State<ExtensionReorderList> {

  BuildContext tContext;

  List<TreeNode> items = [];

  @override
  void initState() {
    super.initState();
    // this.items = reBuildTree();
  }

  Widget build(BuildContext context) {
    // super.build(context);
    this.tContext = context;
    this.items = reBuildTree();
    return ReorderableListView(
      onReorder: nodeOnReorder,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: this.items.map<Widget>(buildListTile).toList(),
    );
  }

  void nodeOnReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    List<TreeNode> objCopy = reBuildTree();
    final TreeNode item = objCopy.removeAt(oldIndex);
    TreeNode oldNode = TreeNode(tid: item.tid, isOpen: item.isOpen, isFolder: item.isFolder, name: item.name, tag: item.tag, loading: item.loading, father: item.father);
    TreeNode node = item;
    objCopy.insert(newIndex, item);

    TreeNode upperTree = (newIndex - 1 >= 0) ? objCopy[newIndex - 1] : null;

    TreeNode newFatherNode;

    // find father
    if (upperTree != null) {
      if (upperTree.isFolder) {
        newFatherNode = upperTree;
      } else {
        newFatherNode = upperTree.father;
      }
    }

    if (!canReorder(oldIndex, newIndex, item, upperTree)) {
      return; // can not reorder for some reasons
    }

    // remove node from old father node
    if (node.isRoot()) {
      this.widget.objectTree.remove(node);
    } else if (node.father != null &&
        node.father.children != null &&
        node.father.children.indexOf(node) != -1) {
      node.father.children.removeAt(node.father.children.indexOf(node));
    }
    
    // insert
    if (newFatherNode == null) {
      // top
      int index =
          upperTree == null ? 0 : this.widget.objectTree.indexOf(upperTree) + 1;
      this.widget.objectTree.insert(index, node);
      node.father = null;
    } else {
      if (newFatherNode.children == null) {
        newFatherNode.children = [];
      }
      if (newFatherNode != null &&
          upperTree != null &&
          upperTree == newFatherNode) {

        if (node.isRoot() && !upperTree.isOpen) {
          // node is root && upperTree is not open
          int index = this.widget.objectTree.indexOf(upperTree) + 1;
          this.widget.objectTree.insert(index, node);
        }
        else {
          if (upperTree.isRoot() && node.isFolder && !upperTree.isOpen) {
          // root level
          int index = this.widget.objectTree.indexOf(upperTree) + 1;
          this.widget.objectTree.insert(index, node);
          node.father = null;
          } else {
            newFatherNode.children.insert(0, node);
            node.father = newFatherNode;
          }
        }
      } else {
        int index = newFatherNode.children.indexOf(upperTree) + 1;
        newFatherNode.children.insert(index, node);
        node.father = newFatherNode;
      }
    }

    if(node != null){
      if(widget.onMoveNode != null){
        widget.onMoveNode(oldNode, node);
      }
      setState((){});
    }
  }

  bool canReorder(int oldIndex, int newIndex, TreeNode node, TreeNode upperNode) {

    if (upperNode != null) {
      if (upperNode.isDescendantOf(node)) {
        print("Can not reorder to children's folder!");
        return false;
      }
    }

    // add more condition for your situation

    return true;
  }

  bOpenedNode(TreeNode treeNode) {
    if(widget.buildOpenedNode != null){
      return widget.buildOpenedNode(treeNode);
    }
    return ListTile(
      onTap: (){
        treeNode.isOpen = !treeNode.isOpen;
        setState((){});
      },
      title: Row(
        children: <Widget>[
          SizedBox(width: widget.indentation * treeNode.treeLevel()),
          const Icon(Icons.indeterminate_check_box),
          const SizedBox(width: 10,),
          Text(treeNode.name)
        ],
      )
    );
  }

  bClosedNode(TreeNode treeNode) {
    if(widget.buildClosedNode != null){
      return widget.buildClosedNode(treeNode);
    }
    return ListTile(
        onTap: (){
          treeNode.isOpen = !treeNode.isOpen;
          setState((){});
        },
        title: Row(
          children: <Widget>[
            SizedBox(width: widget.indentation * treeNode.treeLevel()),
            const Icon(Icons.add_box),
            const SizedBox(width: 10,),
            Text(treeNode.name)
          ],
        )
    );
  }
  
  bNode(TreeNode treeNode) {
    if(widget.buildNode != null){
      return widget.buildNode(treeNode);
    }
    return ListTile(
      onTap: widget.onItemTap == null? null:() {
        widget.onItemTap(treeNode);
      },
      title: Row(
        children: <Widget>[
        SizedBox(width: widget.indentation * treeNode.treeLevel()),
        const Icon(Icons.font_download, color: Colors.grey),
        const SizedBox(width: 10),
          Expanded(
            child: Text(treeNode.name, style: TextStyle(color: Colors.grey[700]),),
          ),
        ]),
      trailing: widget.onItemTap == null? null:Icon(Icons.keyboard_arrow_right),
    );
  }

  bLoadingNode(TreeNode fatherNode){
    if(widget.buildLoadingNode != null){
      return widget.buildLoadingNode();
    }
    return Text('Loading', style: TextStyle(color: Colors.grey));
  }

  Widget buildListTile(TreeNode node) {
    if(node.loading??false){
      return Container(key: GlobalKey(),
      child: bLoadingNode(node),) ;
    }
    if(node.isFolder){
      if(node.isOpen){
        return Container(key: Key(node.tid), child: bOpenedNode(node));
      }
      return Container(key: Key(node.tid), child: bClosedNode(node));
    }
    return Container(key: Key(node.tid), child: bNode(node));
  }

  // void reloadItems() {
  //   this.items = reBuildTree();
  // }

  reBuildTree(){
    List<TreeNode> results = [];
    for(TreeNode item in widget.objectTree){
      results.add(item);
      if(item.isFolder){
        addChildren(item, results);
      }
    }
    return results;
  }

  void addChildren(TreeNode item, List results) {
    if(item.isOpen){
      if(item.children == null){
        if(widget.loadChildren != null){
          widget.loadChildren(item);
          results.add(TreeNode(loading: true, father: item));
        }
      }else{
        for(TreeNode stn in item.children){
          results.add(stn);
          if(stn.isFolder){
            addChildren(stn, results);
          }
        }
      }
    }
  }

}
