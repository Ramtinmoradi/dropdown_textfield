library dropdown_textfield;

import 'package:dropdown_textfield/tooltip_widget.dart';
import 'package:flutter/material.dart';

class CustomDropDown extends StatefulWidget {
  const CustomDropDown({
    Key? key,
    this.initialValue,
    required this.dropDownList,
    this.padding,
    this.textStyle,
    this.onChanged,
    this.validator,
    this.isEnabled = true,
    this.enableSearch = false,
    this.dropdownRadius = 12,
    this.textFieldDecoration,
    this.maxItemCount = 6,
  })  : isMultiSelection = false,
        isForceMultiSelectionClear = false,
        displayCompleteItem = false,
        super(key: key);
  const CustomDropDown.multiSelection({
    Key? key,
    this.displayCompleteItem = false,
    this.initialValue,
    required this.dropDownList,
    this.padding,
    this.textStyle,
    this.isForceMultiSelectionClear = false,
    this.onChanged,
    this.validator,
    this.isEnabled = true,
    this.dropdownRadius = 12,
    this.textFieldDecoration,
    this.maxItemCount = 6,
  })  : isMultiSelection = true,
        enableSearch = false,
        super(key: key);

  ///define the radius of dropdown List ,default value is 12
  final double dropdownRadius;

  ///initial value ,if it is null or not exist in dropDownList then it will not display value
  final String? initialValue;

  ///List<DropDownValues>,List of dropdown values
  final List<DropDownValues> dropDownList;

  ///it is a function,called when value selected from dropdown.
  ///for single Selection Dropdown it will return single DropDownValues object,
  ///and for multi Selection Dropdown ,it will return list of DropDownValues object,
  final ValueSetter? onChanged;

  ///by setting isMultiSelection=true to make multi selection dropdown
  final bool isMultiSelection;
  final TextStyle? textStyle;
  final EdgeInsets? padding;

  ///by setting isForceMultiSelectionClear=true to deselect selected item,only applicable for multi selection dropdown
  final bool isForceMultiSelectionClear;

  ///override default textfield decoration
  final InputDecoration? textFieldDecoration;

  ///by setting isEnabled=false to disable textfield,default value true
  final bool isEnabled;

  final FormFieldValidator<String>? validator;

  ///by setting enableSearch=true enable search option in dropdown,as of now this feature enabled only for single selection dropdown
  final bool enableSearch;

  ///set displayCompleteItem=true, if you want show complete list of item in textfield else it will display like "number_of_item item selected"
  final bool displayCompleteItem;

  ///you can define maximum number dropdown item length,default value is 6
  final int maxItemCount;

  @override
  _CustomDropDownState createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown>
    with TickerProviderStateMixin {
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);

  late TextEditingController _cnt;
  late String hintText;

  late bool isExpanded;
  OverlayEntry? entry;
  final layerLink = LayerLink();
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  List<bool> multiSelectionValue = [];
  // late String selectedItem;
  late double height;
  late List<DropDownValues> dropDownList;
  late int maxListItem;
  late double searchWidgetHeight;
  late FocusNode searchFocusNode;
  late FocusNode textFieldFocusNode;
  late bool isSearch;
  @override
  void initState() {
    searchFocusNode = FocusNode();
    textFieldFocusNode = FocusNode();
    isSearch = false;
    dropDownList = List.from(widget.dropDownList);
    isExpanded = false;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _heightFactor = _controller.drive(_easeInTween);
    for (int i = 0; i < dropDownList.length; i++) {
      multiSelectionValue.add(false);
    }
    searchWidgetHeight = 60;
    hintText = "Select Item";
    String? initialValue;
    if (widget.initialValue != null) {
      var index = dropDownList.indexWhere(
          (element) => element.name.trim() == widget.initialValue!.trim());
      if (index != -1) {
        initialValue = widget.initialValue;
      }
    }
    _cnt = TextEditingController(text: initialValue);
    maxListItem = widget.maxItemCount;
    height = !widget.isMultiSelection
        ? dropDownList.length < maxListItem
            ? dropDownList.length * 50
            : 50 * maxListItem.toDouble()
        : dropDownList.length < 6
            ? dropDownList.length * 50
            : 50 * maxListItem.toDouble();

    searchFocusNode.addListener(() {
      if (!searchFocusNode.hasFocus &&
          !textFieldFocusNode.hasFocus &&
          isExpanded &&
          !widget.isMultiSelection) {
        isExpanded = !isExpanded;
        hideOverlay();
      }
    });
    textFieldFocusNode.addListener(() {
      if (!searchFocusNode.hasFocus &&
          !textFieldFocusNode.hasFocus &&
          isExpanded) {
        isExpanded = !isExpanded;
        hideOverlay();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isForceMultiSelectionClear) {
      multiSelectionValue = [];
      _cnt.text = "";
      for (int i = 0; i < dropDownList.length; i++) {
        multiSelectionValue.add(false);
      }
    }
    return CompositedTransformTarget(
      link: layerLink,
      child: TextFormField(
        focusNode: textFieldFocusNode,
        style: widget.textStyle,
        enabled: widget.isEnabled,
        readOnly: true,
        controller: _cnt,
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
          if (isExpanded) {
            _showOverlay();
          } else {
            hideOverlay();
          }
        },
        validator: (value) => widget.validator != null
            ? widget.validator!(value != "" ? value : null)
            : null,
        decoration: widget.textFieldDecoration != null
            ? widget.textFieldDecoration!.copyWith(
                hintText: hintText,
                suffixIcon: _cnt.text.isEmpty
                    ? const Icon(
                        Icons.arrow_drop_down_outlined,
                      )
                    : InkWell(
                        onTap: () {
                          _cnt.clear();
                          if (widget.onChanged != null) {
                            widget
                                .onChanged!(widget.isMultiSelection ? [] : "");
                          }
                          multiSelectionValue = [];
                          for (int i = 0; i < dropDownList.length; i++) {
                            multiSelectionValue.add(false);
                          }
                          setState(() {});
                        },
                        child: const Icon(
                          Icons.clear,
                        ),
                      ),
              )
            : InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: hintText,
                hintStyle: const TextStyle(fontWeight: FontWeight.normal),
                suffixIcon: _cnt.text.isEmpty
                    ? const Icon(
                        Icons.arrow_drop_down_outlined,
                      )
                    : InkWell(
                        onTap: () {
                          _cnt.clear();
                          if (widget.onChanged != null) {
                            widget
                                .onChanged!(widget.isMultiSelection ? [] : "");
                          }
                          multiSelectionValue = [];
                          for (int i = 0; i < dropDownList.length; i++) {
                            multiSelectionValue.add(false);
                          }
                          setState(() {});
                        },
                        child: const Icon(
                          Icons.clear,
                        ),
                      ),
              ),
      ),
    );
  }

  Future<void> _showOverlay() async {
    _controller.forward();
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    double posFromTop = offset.dy;
    double posFromBot = MediaQuery.of(context).size.height - posFromTop;
    double ht = height + 120 + (widget.enableSearch ? searchWidgetHeight : 0);
    final double htPos = posFromBot < ht ? size.height - 100 : size.height;
    entry = OverlayEntry(
      builder: (context) => Positioned(
          width: size.width,
          child: CompositedTransformFollower(
              targetAnchor:
                  posFromBot < ht ? Alignment.bottomCenter : Alignment.topLeft,
              followerAnchor:
                  posFromBot < ht ? Alignment.bottomCenter : Alignment.topLeft,
              link: layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, htPos),
              child: AnimatedBuilder(
                animation: _controller.view,
                builder: buildOverlay,
              ))),
    );
    overlay?.insert(entry!);
  }

  void hideOverlay() {
    _controller.reverse().then<void>((void value) {
      entry?.remove();
      entry = null;
    });
  }

  Widget buildOverlay(context, child) {
    return ClipRect(
      child: Align(
        heightFactor: _heightFactor.value,
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.all(Radius.circular(widget.dropdownRadius)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: !widget.isMultiSelection
                  ? SingleSelection(
                      mainFocusNode: textFieldFocusNode,
                      searchFocusNode: searchFocusNode,
                      enableSearch: widget.enableSearch,
                      height: height,
                      dropDownList: dropDownList,
                      onChanged: (item) {
                        setState(() {
                          _cnt.text = item.name;
                          isExpanded = !isExpanded;
                        });
                        if (widget.onChanged != null) {
                          widget.onChanged!(item);
                        }
                        // Navigator.pop(context, null);
                        hideOverlay();
                      },
                      searchHeight: searchWidgetHeight,
                    )
                  : MultiSelection(
                      height: height,
                      list: multiSelectionValue,
                      dropDownList: dropDownList,
                      onChanged: (val) {
                        isExpanded = !isExpanded;
                        multiSelectionValue = val;
                        List result = [];
                        List completeList = [];
                        for (int i = 0; i < multiSelectionValue.length; i++) {
                          if (multiSelectionValue[i]) {
                            result.add(dropDownList[i]);
                            completeList.add(dropDownList[i].name);
                          }
                        }
                        int count = multiSelectionValue
                            .where((element) => element)
                            .toList()
                            .length;

                        _cnt.text = (count == 0
                            ? ""
                            : widget.displayCompleteItem
                                ? completeList.join(",")
                                : "$count item selected");
                        if (widget.onChanged != null) {
                          widget.onChanged!(result);
                        }
                        hideOverlay();

                        setState(() {});
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class SingleSelection extends StatefulWidget {
  const SingleSelection(
      {Key? key,
      required this.dropDownList,
      required this.onChanged,
      required this.height,
      required this.enableSearch,
      required this.searchHeight,
      required this.searchFocusNode,
      required this.mainFocusNode})
      : super(key: key);
  final List<DropDownValues> dropDownList;
  final ValueSetter onChanged;
  final double height;
  final bool enableSearch;
  final double searchHeight;
  final FocusNode searchFocusNode;
  final FocusNode mainFocusNode;

  @override
  State<SingleSelection> createState() => _SingleSelectionState();
}

class _SingleSelectionState extends State<SingleSelection> {
  late List<DropDownValues> newDropDownList;
  late TextEditingController _searchCnt;
  late bool isSearch;

  onItemChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        newDropDownList = List.from(widget.dropDownList);
      } else {
        newDropDownList = widget.dropDownList
            .where(
                (item) => item.name.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void initState() {
    newDropDownList = List.from(widget.dropDownList);
    _searchCnt = TextEditingController();
    isSearch = false;
    super.initState();
  }

  @override
  void dispose() {
    _searchCnt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.enableSearch)
          SizedBox(
            height: widget.searchHeight,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                focusNode: widget.searchFocusNode,
                controller: _searchCnt,
                decoration: InputDecoration(
                  hintText: 'Search Here...',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      widget.mainFocusNode.requestFocus();
                      _searchCnt.clear();
                      onItemChanged("");
                    },
                    child: widget.searchFocusNode.hasFocus
                        ? const InkWell(
                            child: Icon(Icons.close),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                onChanged: onItemChanged,
              ),
            ),
          ),
        SizedBox(
          height: widget.height,
          child: Scrollbar(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: newDropDownList.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    widget.onChanged(newDropDownList[index]);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(newDropDownList[index].name,
                          style: Theme.of(context).textTheme.subtitle1),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class MultiSelection extends StatefulWidget {
  const MultiSelection({
    Key? key,
    required this.onChanged,
    required this.dropDownList,
    required this.list,
    required this.height,
  }) : super(key: key);
  final List<DropDownValues> dropDownList;
  final ValueSetter onChanged;
  final List<bool> list;
  final double height;

  @override
  _MultiSelectionState createState() => _MultiSelectionState();
}

class _MultiSelectionState extends State<MultiSelection> {
  List<bool> multiSelectionValue = [];

  @override
  void initState() {
    multiSelectionValue = List.from(widget.list);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: Scrollbar(
            child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.dropDownList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(widget.dropDownList[index].name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1),
                                ),
                                if (widget.dropDownList[index].toolTipMsg !=
                                    null)
                                  ToolTipWidget(
                                      msg: widget
                                          .dropDownList[index].toolTipMsg!)
                              ],
                            ),
                          ),
                        ),
                      ),
                      Checkbox(
                        value: multiSelectionValue[index],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              multiSelectionValue[index] = value;
                            });
                          }
                        },
                      ),
                    ],
                  );
                }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 5, top: 15),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
                height: 40,
                width: 50,
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  color: Colors.green,
                  child: const FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      "Ok",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  onPressed: () {
                    widget.onChanged(multiSelectionValue);
                  },
                )),
          ),
        ),
      ],
    );
  }
}

class DropDownValues {
  final String name;
  final String value;

  ///as of now only added for multiselection dropdown
  final String? toolTipMsg;

  DropDownValues({required this.name, required this.value, this.toolTipMsg});
}
