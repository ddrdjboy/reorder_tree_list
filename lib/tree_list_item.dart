class TreeNode {

  bool loading;
  String tid;
  bool isOpen;
  bool isFolder;

  TreeNode father;
  List<TreeNode> children;
  
  String name;

  dynamic tag;

  static int treeLevelMax = 10;

  TreeNode({String tid, bool isOpen, bool isFolder, this.name, this.tag, this.loading, this.father}) {
    this.tid = tid;
    this.isOpen = (isOpen == null ? false : isOpen);
    this.isFolder = (isFolder == null ? false : isFolder);
  }

  // override
  bool isRoot() {
    return this.father == null;
  }

  // override
  bool isEqual(TreeNode another) {
    return this.tid == another.tid;
  }

  bool isDescendantOf(TreeNode another) {
    TreeNode obj = this;
    while (!obj.isRoot()) {
      TreeNode father = obj.father;
      if (this.isEqual(father)) {
        return true;
      } else {
        obj = obj.father;
      }
    }

    return false;
  }

  static TreeNode findFatherByFatherId(List<TreeNode> items, String fatherId) {
    
    for (TreeNode item in items) {
      if (item.tid == fatherId) {
        return item;
      }
    }
    return null;
  }

  TreeNode findFather(List<TreeNode> objs) {
    if (!isRoot()) {
      for (TreeNode obj in objs) {
        if (obj.isEqual(this.father)) {
          return obj;
        }
      }
    }
    return null;
  }

  int treeLevel() {
    TreeNode aItem = this;
    int level = 0;
    while (aItem != null && !aItem.isRoot()) {
      level += 1;
      if (level >= treeLevelMax) {
        level = treeLevelMax;
        break;
      }
      aItem = aItem.father;
    }
    return level;
  }

  // 在兄弟们中排行第几
  int indexOfFather() {
    if (isRoot()) {
      return -1;
    } else {
      return this.father != null ? this.father.children.indexOf(this) : 0;
    }
  }
}