import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import 'dart:math';

class GameViewModel extends ChangeNotifier {
  late MiniGalpon _galpon;
  bool _gameOver = false;
  String _mensaje = '';
  bool _enProgreso = false;

  GameViewModel() {
    iniciarJuego();
  }

  // Getters
  MiniGalpon get galpon => _galpon;
  bool get gameOver => _gameOver;
  String get mensaje => _mensaje;
  bool get enProgreso => _enProgreso;

  /// Getter para alerta de salud (CORREGIDO)
  String get alertaSalud => _galpon.saludPromedio < 30 
    ? '🚨 Alerta: Enfermedad grave. Salud: ${_galpon.saludPromedio.toStringAsFixed(1)}'
    : '✅ Salud normal: ${_galpon.saludPromedio.toStringAsFixed(1)}';

  /// Inicia un nuevo juego
  void iniciarJuego() {
    _galpon = MiniGalpon();
    _gameOver = false;
    _mensaje = '¡Bienvenido! a SimuGalpon ';
    notifyListeners();
  }

  /// Avanza un día del simulador
  void avanzarDia() {
    if (_gameOver) return;

    _enProgreso = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () {
      final random = Random();
      
      // Producción de huevos (varía según comida)
      int huevosDelDia = 
          ((_galpon.gallinas * _galpon.comidaKg / 100) * (0.8 + random.nextDouble() * 0.3)).toInt();

      // Consumo de comida
      double comidaConsumida = _galpon.gallinas * 0.15;
      
      if (_galpon.comidaKg < comidaConsumida) {
        huevosDelDia = (huevosDelDia * 0.5).toInt();
        _mensaje = 'No hay suficiente comida! Producción reducida.';
      }

      // Actualizar recursos
      double comidaNueva = (_galpon.comidaKg - comidaConsumida).clamp(0, double.infinity);
      int huevosNuevos = _galpon.huevosProducidos + huevosDelDia;
      double presupuestoNuevo = _galpon.presupuesto + _galpon.calcularGanancia();

      // Salud varía aleatoriamente
      double saludNueva = (_galpon.saludPromedio + (random.nextDouble() - 0.5) * 10)
          .clamp(10, 100);

      // Eventos aleatorios
      List<String> eventosNuevos = [..._galpon.eventos];
      if (random.nextDouble() < 0.15) {
        String evento = _generarEvento(random);
        eventosNuevos.add(evento);
        
        // Aplicar efectos del evento
        if (evento.contains('Enfermedad')) {
          saludNueva = (saludNueva * 0.85).clamp(10, 100);
          presupuestoNuevo -= 50;
        } else if (evento.contains('Buen clima')) {
          huevosDelDia = (huevosDelDia * 1.2).toInt();
        }
      }

      // Actualizar estado
      _galpon = _galpon.copyWith(
        huevosProducidos: huevosNuevos,
        comidaKg: comidaNueva,
        presupuesto: presupuestoNuevo.clamp(0, double.infinity),
        saludPromedio: saludNueva,
        diasTranscurridos: _galpon.diasTranscurridos + 1,
        eventos: eventosNuevos.length > 5 
            ? eventosNuevos.sublist(eventosNuevos.length - 5)
            : eventosNuevos,
      );

      // Verificar fin del juego
      if (!_galpon.estaViable()) {
        _gameOver = true;
        _mensaje = '❌ ¡Juego Terminado! Tu galpón no fue viable.';
      }

      _enProgreso = false;
      notifyListeners();
    });
  }

  /// Comprar comida
  void comprarComida(double kilos) {
    final costo = kilos * 1.2;
    if (_galpon.presupuesto >= costo) {
      _galpon = _galpon.copyWith(
        comidaKg: _galpon.comidaKg + kilos,
        presupuesto: _galpon.presupuesto - costo,
      );
      _mensaje = '✅ Compraste $kilos kg de comida';
      notifyListeners();
    } else {
      _mensaje = '❌ Presupuesto insuficiente';
      notifyListeners();
    }
  }

  /// Vender huevos
  void venderHuevos(int cantidad) {
    if (_galpon.huevosProducidos >= cantidad) {
      _galpon = _galpon.copyWith(
        huevosProducidos: _galpon.huevosProducidos - cantidad,
        presupuesto: _galpon.presupuesto + (cantidad * 2.5),
      );
      _mensaje = ' Vendiste $cantidad huevos';
      notifyListeners();
    } else {
      _mensaje = ' No hay suficientes huevos para vender';
      notifyListeners();
    }
  }

  /// Medicar gallinas (mejora salud)
  void medicarGallinas() {
    final costo = 75.0;
    if (_galpon.presupuesto >= costo) {
      _galpon = _galpon.copyWith(
        saludPromedio: 95.0,
        presupuesto: _galpon.presupuesto - costo,
      );
      _mensaje = ' la salud de las gallinas ha sido mejorada';
      notifyListeners();
    } else {
      _mensaje = 'No tienes presupuesto insuficiente para medicinas';
      notifyListeners();
    }
  }

  /// Comprar más gallinas
  void comprarGallinas(int cantidad) {
    final costo = cantidad * 20.0;
    if (_galpon.presupuesto >= costo) {
      _galpon = _galpon.copyWith(
        gallinas: _galpon.gallinas + cantidad,
        presupuesto: _galpon.presupuesto - costo,
      );
      _mensaje = ' Compraste $cantidad gallinas';
      notifyListeners();
    } else {
      _mensaje = ' Presupuesto insuficiente';
      notifyListeners();
    }
  }

  /// Verificar enfermedad (CORREGIDO)
  String verificarEnfermedad(double saludPromedio) {
    if (saludPromedio < 30) {
      return '🚨 ALERTA CRÍTICA: Enfermedad grave. Salud: ${saludPromedio.toStringAsFixed(1)}';
    } else if (saludPromedio < 60) {
      return '⚠️ Alerta moderada: Salud en ${saludPromedio.toStringAsFixed(1)}';
    }
    return '✅ Salud normal: ${saludPromedio.toStringAsFixed(1)}';
  }

  /// Genera eventos aleatorios (CORREGIDO)
  String _generarEvento(Random random) {
    // Lista base de eventos estáticos
    final List<String> eventosBase = [
      'Esta haciendo un buen clima para la produccion',
      'Enfermedad detectada en el galpón',
      'Una gallina escapó',
      'Excelente producción hoy',
      'Baja producción por estrés',
      'Día soleado y cálido',
    ];

    // Agregar evento dinámico basado en la salud
    List<String> todosEventos = List.from(eventosBase);
    String eventoSalud = verificarEnfermedad(_galpon.saludPromedio);
    
    // Solo agregar como evento si no es "Salud normal"
    if (!eventoSalud.contains('Salud normal')) {
      todosEventos.add(eventoSalud);
    }

    return todosEventos[random.nextInt(todosEventos.length)];
  }

  /// Otra opción más simple para _generarEvento:
  String _generarEventoSimple(Random random) {
    final eventos = [
      'Esta haciendo un buen clima para la produccion',
      'Enfermedad detectada en el galpón',
      'Una gallina escapó',
      'Excelente producción hoy',
      'Baja producción por estrés',
      'Día soleado y cálido',
      // Nota: No puedes llamar funciones aquí directamente
    ];
    
    // Puedes condicionar qué eventos mostrar
    String eventoSeleccionado = eventos[random.nextInt(eventos.length)];
    
    // Si el evento seleccionado es "Enfermedad" y la salud es buena,
    // podrías cambiarlo por otro evento
    if (eventoSeleccionado.contains('Enfermedad') && _galpon.saludPromedio > 70) {
      eventoSeleccionado = 'Día soleado y cálido'; // Evento alternativo
    }
    
    return eventoSeleccionado;
  }
}