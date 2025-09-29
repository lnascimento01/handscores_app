import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handscore/features/auth/data/state/auth_providers.dart';

class MfaPage extends ConsumerStatefulWidget {
  const MfaPage({super.key});

  @override
  ConsumerState<MfaPage> createState() => _MfaPageState();
}

class _MfaPageState extends ConsumerState<MfaPage> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final ctrl = ref.read(authControllerProvider.notifier);

    final channels = state.mfaChannels;
    final selected =
        state.selectedChannel ?? (channels.isNotEmpty ? channels.first : null);
    final isLoading = state.flow == AuthFlow.loading;
    final canSend = !isLoading && selected != null && state.countdown == 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Verificação MFA')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Seleção de canal (se houver mais de um)
            if (channels.length > 1)
              DropdownButtonFormField<String>(
                value: selected,
                items: channels
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: isLoading
                    ? null
                    : (c) {
                        if (c != null) {
                          ctrl.requestMfaChannel(
                            c,
                          ); // já reemite o challenge no canal escolhido
                        }
                      },
                decoration: const InputDecoration(
                  labelText: 'Canal de verificação',
                ),
              )
            else if (selected != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Canal: ${selected.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

            const SizedBox(height: 12),

            // Botão de enviar / reenviar
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: canSend
                    ? () => ctrl.requestMfaChannel(selected)
                    : null,
                child: Text(
                  state.countdown > 0
                      ? 'Reenviar em ${state.countdown}s'
                      : 'Enviar código',
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Campo código
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Código de 6 dígitos',
                hintText: '000000',
                counterText: '',
              ),
              enabled: !isLoading,
            ),

            const SizedBox(height: 12),

            // Confirmar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => ctrl.verifyMfa(_code.text.trim()),
                child: Text(isLoading ? 'Verificando...' : 'Confirmar'),
              ),
            ),

            if (state.error != null) ...[
              const SizedBox(height: 12),
              Text(state.error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
