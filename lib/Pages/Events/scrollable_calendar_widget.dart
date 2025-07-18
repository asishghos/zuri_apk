import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScrollableCalendarWidget extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime)? onDateSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final Color todayColor;
  final double itemWidth;
  final double itemHeight;
  final double borderRadius;
  final double spacing;

  const ScrollableCalendarWidget({
    Key? key,
    this.initialDate,
    this.startDate,
    this.endDate,
    this.onDateSelected,
    this.selectedColor = const Color(0xFFE25C7E),
    this.unselectedColor = Colors.white,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = Colors.black,
    this.todayColor = const Color(0xFF42A5F5),
    this.itemWidth = 80.0,
    this.itemHeight = 80.0,
    this.borderRadius = 20.0,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  State<ScrollableCalendarWidget> createState() =>
      _ScrollableCalendarWidgetState();
}

class _ScrollableCalendarWidgetState extends State<ScrollableCalendarWidget> {
  late ScrollController _scrollController;
  late DateTime selectedDate;
  late DateTime startDate;
  late DateTime endDate;
  late List<DateTime> dateList;
  final DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Set date range (default: 1 year from today)
    startDate =
        widget.startDate ?? DateTime(today.year - 1, today.month, today.day);
    endDate =
        widget.endDate ?? DateTime(today.year + 1, today.month, today.day);

    // Set initial selected date
    selectedDate = widget.initialDate ?? today;

    // Generate date list
    _generateDateList();

    // Scroll to initial date after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate(selectedDate);
    });
  }

  void _generateDateList() {
    dateList = [];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      dateList.add(
        DateTime(currentDate.year, currentDate.month, currentDate.day),
      );
      currentDate = currentDate.add(const Duration(days: 1));
    }
  }

  void _scrollToDate(DateTime date) {
    final index = dateList.indexWhere(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );

    if (index != -1) {
      final scrollPosition = index * (widget.itemWidth + widget.spacing);
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  bool _isToday(DateTime date) {
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool _isSelected(DateTime date) {
    return date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
  }

  Color _getBackgroundColor(DateTime date) {
    if (_isSelected(date)) return widget.selectedColor;
    if (_isToday(date)) return widget.todayColor;
    return widget.unselectedColor;
  }

  Color _getTextColor(DateTime date) {
    if (_isSelected(date) || _isToday(date)) return widget.selectedTextColor;
    return widget.unselectedTextColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // // Date picker header with navigation
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       IconButton(
        //         onPressed: () {
        //           final newDate = selectedDate.subtract(
        //             const Duration(days: 30),
        //           );
        //           if (newDate.isAfter(startDate) ||
        //               newDate.isAtSameMomentAs(startDate)) {
        //             setState(() {
        //               selectedDate = newDate;
        //             });
        //             _scrollToDate(selectedDate);
        //           }
        //         },
        //         icon: const Icon(Icons.chevron_left),
        //       ),
        //       GestureDetector(
        //         onTap: () {
        //           // Go to today
        //           setState(() {
        //             selectedDate = today;
        //           });
        //           _scrollToDate(today);
        //           widget.onDateSelected?.call(today);
        //         },
        //         child: Text(
        //           '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
        //           style: const GoogleFonts.libreFranklin(
        //             fontSize: MediaQuery.of(context).textScaler.scale(18),
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //       ),
        //       IconButton(
        //         onPressed: () {
        //           final newDate = selectedDate.add(const Duration(days: 30));
        //           if (newDate.isBefore(endDate) ||
        //               newDate.isAtSameMomentAs(endDate)) {
        //             setState(() {
        //               selectedDate = newDate;
        //             });
        //             _scrollToDate(selectedDate);
        //           }
        //         },
        //         icon: const Icon(Icons.chevron_right),
        //       ),
        //     ],
        //   ),
        // ),

        // Scrollable date list
        Container(
          height: widget.itemHeight,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: dateList.length,
            itemBuilder: (context, index) {
              final date = dateList[index];
              final isSelected = _isSelected(date);
              final isToday = _isToday(date);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                  });
                  widget.onDateSelected?.call(date);
                },
                child: Container(
                  width: widget.itemWidth,
                  height: widget.itemHeight,
                  margin: EdgeInsets.only(
                    right: index < dateList.length - 1 ? widget.spacing : 0,
                  ),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(date),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: isSelected
                          ? widget.selectedColor
                          : isToday
                          ? widget.todayColor
                          : widget.selectedColor,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date.day.toString(),
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(18),
                          fontWeight: FontWeight.w600,
                          color: _getTextColor(date),
                        ),
                      ),
                      Text(
                        _getMonthName(date.month),
                        style: GoogleFonts.libreFranklin(
                          fontSize: 13,
                          color: _getTextColor(date),
                        ),
                      ),
                      if (isToday && !isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: widget.selectedTextColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
