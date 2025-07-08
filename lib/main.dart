import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _currentValue = '0';
  String _previousValue = '';
  String _operation = '';
  bool _waitingForOperand = false;
  String _previousExpression = '';
  String _errorMessage = '';

  void _handleNumber(String number) {
    setState(() {
      _errorMessage = '';
      if (_waitingForOperand) {
        _currentValue = number;
        _waitingForOperand = false;
      } else {
        _currentValue = _currentValue == '0' ? number : _currentValue + number;
      }
    });
  }

  void _handleDecimal() {
    setState(() {
      _errorMessage = '';
      if (_waitingForOperand) {
        _currentValue = '0.';
        _waitingForOperand = false;
      } else if (!_currentValue.contains('.')) {
        _currentValue = _currentValue + '.';
      }
    });
  }

  void _handleOperation(String operation) {
    setState(() {
      _errorMessage = '';
      double inputValue = double.parse(_currentValue);

      if (_previousValue.isEmpty) {
        _previousValue = inputValue.toString();
        _previousExpression = '$inputValue $operation';
        _waitingForOperand = true;
        _operation = operation;
      } else if (_operation.isNotEmpty) {
        double previousValue = double.parse(_previousValue);
        double? result = _calculate(previousValue, inputValue, _operation);
        
        if (result != null) {
          _currentValue = _formatResult(result);
          _previousValue = result.toString();
          _previousExpression = '$result $operation';
          _waitingForOperand = true;
          _operation = operation;
        }
      } else {
        _previousValue = inputValue.toString();
        _previousExpression = '$inputValue $operation';
        _waitingForOperand = true;
        _operation = operation;
      }
    });
  }

  void _calculateResult() {
    setState(() {
      _errorMessage = '';
      double inputValue = double.parse(_currentValue);

      if (_previousValue.isNotEmpty && _operation.isNotEmpty) {
        double previousValue = double.parse(_previousValue);
        double? result = _calculate(previousValue, inputValue, _operation);
        
        if (result != null) {
          _previousExpression = '$previousValue $_operation $inputValue =';
          _currentValue = _formatResult(result);
          _previousValue = '';
          _operation = '';
          _waitingForOperand = true;
        }
      }
    });
  }

  double? _calculate(double first, double second, String operation) {
    switch (operation) {
      case '+':
        return first + second;
      case '-':
        return first - second;
      case '×':
        return first * second;
      case '÷':
        if (second == 0) {
          setState(() {
            _errorMessage = 'Cannot divide by zero';
          });
          return null;
        }
        return first / second;
      case '%':
        return first % second;
      default:
        return second;
    }
  }

  String _formatResult(double result) {
    if (result == result.toInt()) {
      return result.toInt().toString();
    } else {
      return result.toStringAsFixed(8).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    }
  }

  void _clearAll() {
    setState(() {
      _currentValue = '0';
      _previousValue = '';
      _operation = '';
      _waitingForOperand = false;
      _previousExpression = '';
      _errorMessage = '';
    });
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.grey[200],
            foregroundColor: textColor ?? Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            elevation: 2,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Display area
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Previous expression
                  Container(
                    height: 30,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _previousExpression,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Current value
                  Text(
                    _currentValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Error message
                  Container(
                    height: 20,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Button area
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Row 1: C, %, ÷, ×
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton(
                          text: 'C',
                          onPressed: _clearAll,
                          backgroundColor: Colors.grey[300],
                          textColor: Colors.black,
                        ),
                        _buildButton(
                          text: '%',
                          onPressed: () => _handleOperation('%'),
                          backgroundColor: Colors.purple,
                          textColor: Colors.white,
                        ),
                        _buildButton(
                          text: '÷',
                          onPressed: () => _handleOperation('÷'),
                          backgroundColor: Colors.pink,
                          textColor: Colors.white,
                        ),
                        _buildButton(
                          text: '×',
                          onPressed: () => _handleOperation('×'),
                          backgroundColor: Colors.pink,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  
                  // Row 2: 7, 8, 9, -
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton(
                          text: '7',
                          onPressed: () => _handleNumber('7'),
                        ),
                        _buildButton(
                          text: '8',
                          onPressed: () => _handleNumber('8'),
                        ),
                        _buildButton(
                          text: '9',
                          onPressed: () => _handleNumber('9'),
                        ),
                        _buildButton(
                          text: '-',
                          onPressed: () => _handleOperation('-'),
                          backgroundColor: Colors.pink,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  
                  // Row 3: 4, 5, 6, +
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton(
                          text: '4',
                          onPressed: () => _handleNumber('4'),
                        ),
                        _buildButton(
                          text: '5',
                          onPressed: () => _handleNumber('5'),
                        ),
                        _buildButton(
                          text: '6',
                          onPressed: () => _handleNumber('6'),
                        ),
                        _buildButton(
                          text: '+',
                          onPressed: () => _handleOperation('+'),
                          backgroundColor: Colors.pink,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  
                  // Row 4: 1, 2, 3, =
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton(
                          text: '1',
                          onPressed: () => _handleNumber('1'),
                        ),
                        _buildButton(
                          text: '2',
                          onPressed: () => _handleNumber('2'),
                        ),
                        _buildButton(
                          text: '3',
                          onPressed: () => _handleNumber('3'),
                        ),
                        _buildButton(
                          text: '=',
                          onPressed: _calculateResult,
                          backgroundColor: Colors.deepPurple,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  
                  // Row 5: 0, ., empty space for layout
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton(
                          text: '0',
                          onPressed: () => _handleNumber('0'),
                          flex: 2,
                        ),
                        _buildButton(
                          text: '.',
                          onPressed: _handleDecimal,
                          backgroundColor: Colors.purple,
                          textColor: Colors.white,
                        ),
                        const Expanded(child: SizedBox()), // Empty space for alignment
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}