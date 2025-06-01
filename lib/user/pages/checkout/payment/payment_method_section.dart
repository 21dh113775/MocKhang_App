import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';

class PaymentMethodSection extends StatelessWidget {
  final CartProvider cartProvider;

  const PaymentMethodSection({Key? key, required this.cartProvider})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Danh sách các phương thức thanh toán
    final paymentMethods = [
      {'id': 'Cash', 'title': 'Tiền mặt khi nhận hàng', 'icon': Icons.money},
      {'id': 'Credit Card', 'title': 'Thẻ tín dụng', 'icon': Icons.credit_card},
      {
        'id': 'E-Wallet',
        'title': 'Ví điện tử',
        'icon': Icons.account_balance_wallet,
      },
      {
        'id': 'Bank Transfer',
        'title': 'Chuyển khoản ngân hàng',
        'icon': Icons.account_balance,
      },
    ];

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề và biểu tượng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Phương thức thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.payment,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 8),

            // Danh sách các tùy chọn thanh toán
            ...paymentMethods.map(
              (method) => _buildPaymentOption(
                id: method['id'] as String,
                title: method['title'] as String,
                icon: method['icon'] as IconData,
                isSelected: cartProvider.paymentMethod == method['id'],
                onSelect: () {
                  cartProvider.setPaymentMethod(method['id'] as String);
                },
              ),
            ),
            const SizedBox(height: 8),

            // Các form chi tiết cho từng phương thức thanh toán
            if (cartProvider.paymentMethod == 'Credit Card')
              _buildCreditCardForm(),
            if (cartProvider.paymentMethod == 'Bank Transfer')
              _buildBankTransferSection(context),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị tùy chọn thanh toán
  Widget _buildPaymentOption({
    required String id,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.withOpacity(0.05) : null,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.blue : Colors.grey.shade700,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Container(
                        margin: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  // Form nhập thông tin thẻ tín dụng
  Widget _buildCreditCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8, top: 8),
          child: Text(
            'Thông tin thẻ tín dụng',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Số thẻ',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Hết hạn (MM/YY)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Tên chủ thẻ',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // Phần chuyển khoản ngân hàng
  Widget _buildBankTransferSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Thông tin chuyển khoản:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Ngân hàng: Vietcombank'),
              Text('Số tài khoản: 1234567890'),
              Text('Chủ tài khoản: CÔNG TY MOCKHANG'),
              SizedBox(height: 8),
              Text(
                'Nội dung chuyển khoản: [Mã đơn hàng]',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Mã giao dịch ngân hàng',
            hintText: 'Nhập mã giao dịch từ ngân hàng',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            // Lưu mã giao dịch vào provider
            cartProvider.setTransactionCode(value);
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed:
              cartProvider.transactionCode != null &&
                      cartProvider.transactionCode!.isNotEmpty
                  ? () {
                    try {
                      cartProvider.confirmBankTransfer(
                        transactionCode: cartProvider.transactionCode!,
                        amount: cartProvider.total + cartProvider.shippingCost,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Xác nhận thanh toán thành công'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: ${e.toString()}')),
                      );
                    }
                  }
                  : null,
          child: const Text('Xác nhận thanh toán'),
        ),
      ],
    );
  }
}
