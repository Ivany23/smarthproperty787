
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CaptureDocument extends StatefulWidget {
  final String tipoDocumento;

  const CaptureDocument({super.key, required this.tipoDocumento});

  @override
  State<CaptureDocument> createState() => _CaptureDocumentState();
}

class _CaptureDocumentState extends State<CaptureDocument> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      debugPrint("Nenhuma c\u00e2mera dispon\u00edvel.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nenhuma c\u00e2mera encontrada neste dispositivo.")),
        );
      }
      return;
    }
    final firstCamera = cameras.first;

    _controller = CameraController(firstCamera, ResolutionPreset.high, enableAudio: false);

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint("Erro ao inicializar a c\u00e2mera: $e");
    }
  }

  Future<void> _takePictureAndUpload() async {
    if (!_controller!.value.isInitialized) {
      debugPrint("Controlador da c\u00e2mera n\u00e3o inicializado.");
      return;
    }
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final XFile imageFile = await _controller!.takePicture();

      await _uploadDocument(imageFile);

    } catch (e) {
      debugPrint("Erro ao capturar ou enviar o documento: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao processar documento: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _uploadDocument(XFile imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final anuncianteId = prefs.getInt('visitorId'); // Assumindo que 'visitorId' \u00e9 o ID do anunciante

    if (anuncianteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro: ID do anunciante n\u00e3o encontrado. Fa\u00e7a login novamente.")),
      );
      return;
    }

    const String apiUrl = "http://localhost:8080/api/documentos-verificacao/criar";
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    request.fields['anuncianteId'] = anuncianteId.toString();
    request.fields['tipoDocumento'] = widget.tipoDocumento;

    request.files.add(
      await http.MultipartFile.fromPath(
        'documento',
        imageFile.path,
      ),
    );

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documento enviado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Volta para a tela anterior
      } else {
        final responseBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha no upload. C\u00f3digo: ${response.statusCode}, Resposta: $responseBody'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ocorreu um erro de rede: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height * .90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
                const Spacer(),
                Text(
                  "Documento: ${widget.tipoDocumento}",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isCameraInitialized && _controller != null)
                    CameraPreview(_controller!)
                  else
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),

                  Positioned(
                    bottom: 30,
                    height: 50,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ElevatedButton(
                        onPressed: (_isCameraInitialized && !_isUploading) ? _takePictureAndUpload : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.maxFinite, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isUploading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text(
                                "Capturar e Enviar",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                      ),
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
