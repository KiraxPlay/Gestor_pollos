import 'package:flutter/material.dart';

class KPIItem {
  final String titulo;
  final String valor;
  final Color color;
  const KPIItem(this.titulo, this.valor, this.color);
}

class KPIRow extends StatelessWidget {
  final List<KPIItem> items;
  const KPIRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.map((item) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(children: [
              Text(
                item.valor,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: item.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.titulo,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ]),
          ),
        ),
      )).toList(),
    );
  }
}

class SeccionTabla extends StatelessWidget {
  final String titulo;
  final List<String> encabezados;
  final List<List<String>> filas;
  final Color colorHeader;

  const SeccionTabla({
    super.key,
    required this.titulo,
    required this.encabezados,
    required this.filas,
    required this.colorHeader,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (filas.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('Sin registros',
                  style: TextStyle(
                      color: Colors.grey, fontStyle: FontStyle.italic)),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                  colorHeader.withOpacity(0.1)),
              columns: encabezados
                  .map((h) => DataColumn(
                        label: Text(h,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorHeader)),
                      ))
                  .toList(),
              rows: filas
                  .map((f) => DataRow(
                      cells: f.map((c) => DataCell(Text(c))).toList()))
                  .toList(),
            ),
          ),
      ],
    );
  }
}