import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_viewmodel.dart';

class MiniGalponSimulator extends StatelessWidget {
  const MiniGalponSimulator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SimuGalpon'),
        backgroundColor: Colors.yellow[700],
        elevation: 0,
      ),
      body: ChangeNotifierProvider(
        create: (_) => GameViewModel(),
        child: const _GameContent(),
      ),
    );
  }
}

class _GameContent extends StatelessWidget {
  const _GameContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameViewModel>(
      builder: (context, viewModel, _) {
        final galpon = viewModel.galpon;
        final gameOver = viewModel.gameOver;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Mensaje
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: gameOver ? Colors.red[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: gameOver ? Colors.red : Colors.blue,
                    ),
                  ),
                  child: Text(
                    viewModel.mensaje,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: gameOver ? Colors.red[900] : Colors.blue[900],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Estadísticas principales
                _StatsGrid(galpon: galpon),

                const SizedBox(height: 20),

                // Barra de progreso - Salud
                _HealthBar(galpon: galpon),

                const SizedBox(height: 20),

                // Eventos recientes
                if (galpon.eventos.isNotEmpty)
                  _EventsList(eventos: galpon.eventos),

                const SizedBox(height: 20),

                // Botones de acción
                if (!gameOver)
                  _ActionButtons(viewModel: viewModel, galpon: galpon)
                else
                  _GameOverButtons(viewModel: viewModel),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final dynamic galpon;

  const _StatsGrid({required this.galpon});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _StatCard(
          icon: '🐓',
          titulo: 'Gallinas',
          valor: '${galpon.gallinas}',
          color: Colors.amber,
        ),
        _StatCard(
          icon: '🥚',
          titulo: 'Huevos',
          valor: '${galpon.huevosProducidos}',
          color: Colors.brown,
        ),
        _StatCard(
          icon: '💰',
          titulo: 'Presupuesto',
          valor: '\$${galpon.presupuesto.toStringAsFixed(2)}',
          color: Colors.green,
        ),
        _StatCard(
          icon: '🌾',
          titulo: 'Comida (kg)',
          valor: '${galpon.comidaKg.toStringAsFixed(1)}',
          color: Colors.orange,
        ),
        _StatCard(
          icon: '📅',
          titulo: 'Días',
          valor: '${galpon.diasTranscurridos}',
          color: Colors.blue,
        ),
        _StatCard(
          icon: '💸',
          titulo: 'Ganancia/día',
          valor: '\$${galpon.calcularGanancia().toStringAsFixed(2)}',
          color: Colors.teal,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String titulo;
  final String valor;
  final MaterialColor color;

  const _StatCard({
    required this.icon,
    required this.titulo,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[300]!, width: 2),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              color: color[900],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthBar extends StatelessWidget {
  final dynamic galpon;

  const _HealthBar({required this.galpon});

  @override
  Widget build(BuildContext context) {
    final salud = galpon.saludPromedio;
    final color = salud > 70
        ? Colors.green
        : salud > 40
            ? Colors.orange
            : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '❤️ Salud del Galpón: ${salud.toStringAsFixed(1)}%',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: salud / 100,
            minHeight: 20,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _EventsList extends StatelessWidget {
  final List<String> eventos;

  const _EventsList({required this.eventos});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📰 Últimos Eventos:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...eventos.map(
            (evento) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(evento, style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final GameViewModel viewModel;
  final dynamic galpon;

  const _ActionButtons({
    required this.viewModel,
    required this.galpon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botón principal - Avanzar día
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: viewModel.enProgreso ? null : viewModel.avanzarDia,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              disabledBackgroundColor: Colors.grey,
            ),
            child: viewModel.enProgreso
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  )
                : const Text(
                    '⏭️  Avanzar un día',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Grid de acciones
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _ActionButton(
              icon: '🌾',
              label: 'Comprar\nComida',
              onPressed: () => _mostrarDialogComida(context),
            ),
            _ActionButton(
              icon: '🥚',
              label: 'Vender\nHuevos',
              onPressed: () => _mostrarDialogVender(context),
            ),
            _ActionButton(
              icon: '💊',
              label: 'Medicar\n(\$75)',
              onPressed: () => viewModel.medicarGallinas(),
            ),
            _ActionButton(
              icon: '🐓',
              label: 'Comprar\nGallinas',
              onPressed: () => _mostrarDialogGallinas(context),
            ),
          ],
        ),
      ],
    );
  }

  void _mostrarDialogComida(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        int cantidad = 10;
        return AlertDialog(
          title: const Text('🌾 Comprar Comida'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Precio: \$1.20 por kg'),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) => cantidad = int.tryParse(value) ?? 10,
                decoration: const InputDecoration(
                  hintText: 'Cantidad en kg',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.comprarComida(cantidad.toDouble());
                Navigator.pop(context);
              },
              child: const Text('Comprar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogVender(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        int cantidad = 10;
        return AlertDialog(
          title: const Text('🥚 Vender Huevos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Precio: \$2.50 por huevo'),
              Text('Disponibles: ${galpon.huevosProducidos}'),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) => cantidad = int.tryParse(value) ?? 10,
                decoration: const InputDecoration(
                  hintText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.venderHuevos(cantidad);
                Navigator.pop(context);
              },
              child: const Text('Vender'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogGallinas(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        int cantidad = 1;
        return AlertDialog(
          title: const Text('🐓 Comprar Gallinas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Precio: \$20 por gallina'),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) => cantidad = int.tryParse(value) ?? 1,
                decoration: const InputDecoration(
                  hintText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.comprarGallinas(cantidad);
                Navigator.pop(context);
              },
              child: const Text('Comprar'),
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange[300],
        padding: const EdgeInsets.all(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameOverButtons extends StatelessWidget {
  final GameViewModel viewModel;

  const _GameOverButtons({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: viewModel.iniciarJuego,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text(
              ' Jugar de Nuevo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
