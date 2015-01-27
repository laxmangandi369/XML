/*
  This file is part of Daxe.

  Daxe is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Daxe is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Daxe.  If not, see <http://www.gnu.org/licenses/>.
*/

part of daxe;

class MenuBar implements FocusContainer {
  List<Menu> menus;
  bool ignoreClick;
  Menu visibleMenu;
  
  MenuBar() {
    menus = new List<Menu>();
    ignoreClick = false;
    visibleMenu = null;
  }
  
  add(Menu m) {
    menus.add(m);
  }
  
  insert(Menu m, int position) {
    menus.insert(position, m);
  }
  
  h.Element html() {
    h.DivElement div = new h.DivElement();
    div.classes.add('menubar');
    for (Menu m in menus) {
      div.append(createMenuDiv(m));
    }
    h.document.onMouseUp.listen((h.MouseEvent event) => docMouseUp(event));
    return(div);
  }
  
  h.DivElement createMenuDiv(Menu m) {
    h.DivElement divMenu = new h.DivElement();
    divMenu.text = m.title;
    divMenu.id = m.itemid;
    divMenu.classes.add('menu_title');
    divMenu.setAttribute('tabindex', '-1');
    divMenu.onMouseDown.listen((h.MouseEvent event) => mouseDown(event, m));
    divMenu.onMouseOver.listen((h.MouseEvent event) => mouseOver(event, m));
    divMenu.onClick.listen((h.MouseEvent event) => click(m));
    h.Element dropdown = m.htmlMenu();
    dropdown.style.display = 'none';
    divMenu.append(dropdown);
    return(divMenu);
  }
  
  void mouseDown(h.MouseEvent event, Menu m) {
    event.preventDefault();
    if (!m.isVisible()) {
      showMenu(m);
      ignoreClick = true;
      page.focusManager.setFocus(m.parent, m);
    } else {
      ignoreClick = false;
    }
  }
  
  void mouseOver(h.MouseEvent event, Menu m) {
    if (visibleMenu == null || visibleMenu == m)
      return;
    hideMenu(visibleMenu);
    showMenu(m);
    page.focusManager.setFocus(m.parent, m);
  }
  
  void click(Menu m) {
    if (ignoreClick) {
      return;
    }
    if (!m.isVisible()) {
      showMenu(m);
    } else {
      hideMenu(m);
    }
  }
  
  void docMouseUp(h.MouseEvent event) {
    if (visibleMenu == null)
      return;
    h.DivElement divMenu = h.querySelector("#${visibleMenu.itemid}");
    h.Rectangle r = divMenu.getBoundingClientRect();
    if (event.client.x < r.left || event.client.x > r.right ||
        event.client.y < r.top || event.client.y > r.bottom) {
      hideMenu(visibleMenu);
      ignoreClick = true;
    }
  }
  
  void showMenu(Menu m) {
    visibleMenu = m;
    h.DivElement divMenu = h.querySelector("#${m.itemid}");
    divMenu.classes.add('selected');
    m.show();
  }
  
  void hideMenu(Menu m) {
    visibleMenu = null;
    h.DivElement divMenu = h.querySelector("#${m.itemid}");
    divMenu.classes.remove('selected');
    m.hide();
  }
  
  // FocusManager attributes and methods
  
  int nextFocusKey = h.KeyCode.RIGHT;
  bool nextFocusShift = false;
  int previousFocusKey = h.KeyCode.LEFT;
  bool previousFocusShift = false;
  int selectKey = h.KeyCode.ENTER;
  int selectSubContainerKey = h.KeyCode.DOWN;
  bool selectSubContainerShift = false;
  int selectParentContainerKey = h.KeyCode.ESC;
  bool selectParentContainerShift = false;
  
  FocusContainer get parentFocusContainer {
    return page;
  }
  
  focusItem(Object item) {
    assert(menus.contains(item));
    if (visibleMenu != null)
      hideMenu(visibleMenu);
    showMenu(item);
    (item as Menu).getItemHTMLNode().focus();
  }
  
  unfocusItem(Object item) {
    assert(menus.contains(item));
    (item as Menu).getItemHTMLNode().blur();
    hideMenu(item);
  }
  
  selectItem(Object item) {
    assert(menus.contains(item));
    focusItem(item);
  }
  
  List<Object> get focusableItems {
    List<Menu> items = new List<Menu>();
    for (Menu m in menus) {
      if (m.enabled)
        items.add(m);
    }
    return(items);
  }
}
