import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';
import 'package:mockhang_app/admin/providers/order_provider.dart';
import 'package:provider/provider.dart';

// Trang quản lý thanh toán cho quản trị viên
class PaymentsPageAdmin extends StatefulWidget {
  const PaymentsPageAdmin({Key? key}) : super(key: key);

  @override
  _PaymentsPageAdminState createState() => _PaymentsPageAdminState();
}

class _PaymentsPageAdminState extends State<PaymentsPageAdmin> {
  // Các tùy chọn lọc doanh thu
  String _selectedPeriod = 'Tháng'; // Mặc định chọn hiển thị theo tháng
  DateTime _selectedDate = DateTime.now(); // Ngày được chọn hiện tại
  bool _isLoading = true; // Trạng thái tải dữ liệu

  // Các biến tính toán doanh thu
  double _totalRevenue = 0.0; // Tổng doanh thu
  int _totalProductsSold = 0; // Tổng sản phẩm đã bán
  List<OrderModel> _completedOrders = []; // Danh sách đơn hàng đã hoàn thành

  // Dữ liệu cho biểu đồ
  List<FlSpot> _revenueSpots = [];

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu doanh thu sau khi widget được render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRevenueData();
    });
  }

  // Tải dữ liệu doanh thu từ provider
  Future<void> _loadRevenueData() async {
    try {
      setState(() => _isLoading = true);

      // Lấy provider quản lý đơn hàng
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.loadAllOrders();

      // Lọc các đơn hàng đã được giao thành công
      _completedOrders =
          orderProvider.orders
              .where((order) => order.status == 'Đã giao hàng')
              .toList();

      // Tính toán và tạo dữ liệu biểu đồ
      _calculateRevenue();
      _generateChartData();
    } catch (e) {
      // Hiển thị thông báo lỗi nếu không tải được dữ liệu
      _showErrorSnackBar('Lỗi tải dữ liệu doanh thu: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Tính toán tổng doanh thu và số sản phẩm đã bán
  void _calculateRevenue() {
    _totalRevenue = 0.0;
    _totalProductsSold = 0;

    for (var order in _completedOrders) {
      // Lọc đơn hàng theo kỳ đã chọn
      bool shouldInclude = _filterOrderByPeriod(order);
      if (shouldInclude) {
        _totalRevenue += order.totalAmount;
        _totalProductsSold += order.items.length;
      }
    }
  }

  // Lọc đơn hàng theo kỳ đã chọn (ngày/tháng/năm)
  bool _filterOrderByPeriod(OrderModel order) {
    switch (_selectedPeriod) {
      case 'Ngày':
        return _isSameDay(order.dateTime, _selectedDate);
      case 'Tháng':
        return order.dateTime.year == _selectedDate.year &&
            order.dateTime.month == _selectedDate.month;
      case 'Năm':
        return order.dateTime.year == _selectedDate.year;
      default:
        return true;
    }
  }

  // Kiểm tra xem hai ngày có trùng nhau không
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Tạo dữ liệu cho biểu đồ theo kỳ đã chọn
  void _generateChartData() {
    _revenueSpots.clear();

    switch (_selectedPeriod) {
      case 'Ngày':
        _generateDailyChartData();
        break;
      case 'Tháng':
        _generateMonthlyChartData();
        break;
      case 'Năm':
        _generateYearlyChartData();
        break;
    }
  }

  // Tạo dữ liệu biểu đồ theo giờ
  void _generateDailyChartData() {
    _revenueSpots = List.generate(24, (index) {
      double revenue = _calculateHourlyRevenue(index);
      return FlSpot(index.toDouble(), revenue);
    });
  }

  // Tính toán doanh thu theo từng giờ
  double _calculateHourlyRevenue(int hour) {
    return _completedOrders
        .where(
          (order) =>
              order.dateTime.hour == hour &&
              _isSameDay(order.dateTime, _selectedDate),
        )
        .fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  // Tạo dữ liệu biểu đồ theo tháng
  void _generateMonthlyChartData() {
    int daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;

    _revenueSpots = List.generate(daysInMonth, (index) {
      DateTime currentDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        index + 1,
      );
      double dailyRevenue = _completedOrders
          .where((order) => _isSameDay(order.dateTime, currentDate))
          .fold(0.0, (sum, order) => sum + order.totalAmount);

      return FlSpot((index + 1).toDouble(), dailyRevenue);
    });
  }

  // Tạo dữ liệu biểu đồ theo năm
  void _generateYearlyChartData() {
    _revenueSpots = List.generate(12, (index) {
      double monthlyRevenue = _completedOrders
          .where(
            (order) =>
                order.dateTime.year == _selectedDate.year &&
                order.dateTime.month == index + 1,
          )
          .fold(0.0, (sum, order) => sum + order.totalAmount);

      return FlSpot((index + 1).toDouble(), monthlyRevenue);
    });
  }

  // Hiển thị thông báo lỗi
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Xây dựng biểu đồ doanh thu sử dụng Syncfusion
  Widget _buildRevenueChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(title: AxisTitle(text: _getXAxisTitle())),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Doanh Thu (VNĐ)'),
        numberFormat: NumberFormat('#,###'),
      ),
      title: ChartTitle(text: 'Biểu Đồ Doanh Thu'),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x : point.y VNĐ',
      ),
      series: <ColumnSeries<FlSpot, String>>[
        ColumnSeries<FlSpot, String>(
          dataSource: _revenueSpots,
          xValueMapper: (FlSpot spot, _) => _getChartXAxisLabel(spot.x.toInt()),
          yValueMapper: (FlSpot spot, _) => spot.y,
          color: Colors.blue,
          dataLabelMapper:
              (FlSpot spot, _) =>
                  spot.y > 0 ? NumberFormat('#,###').format(spot.y) : '',
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(fontSize: 10, color: Colors.black),
          ),
        ),
      ],
    );
  }

  // Lấy tiêu đề trục X
  String _getXAxisTitle() {
    switch (_selectedPeriod) {
      case 'Ngày':
        return 'Giờ';
      case 'Tháng':
        return 'Ngày';
      case 'Năm':
        return 'Tháng';
      default:
        return '';
    }
  }

  // Lấy nhãn trục X
  String _getChartXAxisLabel(int index) {
    switch (_selectedPeriod) {
      case 'Ngày':
        return '$index h';
      case 'Tháng':
        return '${index + 1}';
      case 'Năm':
        return 'T${index + 1}';
      default:
        return '';
    }
  }

  // Thay đổi kỳ hiển thị (ngày/tháng/năm)
  void _changePeriod(String? newPeriod) {
    if (newPeriod != null) {
      setState(() {
        _selectedPeriod = newPeriod;
        _loadRevenueData();
      });
    }
  }

  // Thay đổi ngày/tháng/năm được chọn
  void _changeDate() async {
    DateTime? pickedDate;

    switch (_selectedPeriod) {
      case 'Ngày':
        pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        break;
      case 'Tháng':
        pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDatePickerMode: DatePickerMode.year,
        );
        break;
      case 'Năm':
        pickedDate = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Chọn năm'),
              content: SizedBox(
                width: 300,
                height: 300,
                child: YearPicker(
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  selectedDate: _selectedDate,
                  onChanged: (DateTime dateTime) {
                    Navigator.pop(context, dateTime);
                  },
                ),
              ),
            );
          },
        );
        break;
    }

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate!;
        _loadRevenueData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý Doanh thu')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Chọn kỳ và ngày
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              value: _selectedPeriod,
                              items:
                                  ['Ngày', 'Tháng', 'Năm']
                                      .map(
                                        (period) => DropdownMenuItem(
                                          value: period,
                                          child: Text(period),
                                        ),
                                      )
                                      .toList(),
                              onChanged: _changePeriod,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _changeDate,
                            child: Text(
                              _selectedPeriod == 'Ngày'
                                  ? DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(_selectedDate)
                                  : _selectedPeriod == 'Tháng'
                                  ? DateFormat('MM/yyyy').format(_selectedDate)
                                  : DateFormat('yyyy').format(_selectedDate),
                            ),
                          ),
                        ],
                      ),

                      // Tóm tắt doanh thu
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Tổng Doanh Thu',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                '${NumberFormat('#,###').format(_totalRevenue)} VNĐ',
                                style: Theme.of(
                                  context,
                                ).textTheme.displaySmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Tổng Sản Phẩm Bán Được: $_totalProductsSold',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Biểu đồ doanh thu
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Biểu Đồ Doanh Thu',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(
                                height: 300,
                                child: _buildRevenueChart(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Chi tiết đơn hàng
                      Card(
                        child: ExpansionTile(
                          title: Text('Chi Tiết Đơn Hàng'),
                          children:
                              _completedOrders
                                  .where(_filterOrderByPeriod)
                                  .map(
                                    (order) => ListTile(
                                      title: Text(
                                        'Đơn hàng #${order.orderId.substring(0, 8)}',
                                      ),
                                      subtitle: Text(
                                        '${NumberFormat('#,###').format(order.totalAmount)} VNĐ',
                                      ),
                                      trailing: Text(
                                        DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(order.dateTime),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
