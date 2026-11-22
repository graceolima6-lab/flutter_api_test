import 'package:flutter/material.dart';
import 'models/etudiant.dart';
import 'services/etudiant_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liste des Étudiants',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class EtudiantListPage extends StatefulWidget {
  const EtudiantListPage({super.key});

  @override
  State<EtudiantListPage> createState() => _EtudiantListPageState();
}

class _EtudiantListPageState extends State<EtudiantListPage> {
  final EtudiantService _service = EtudiantService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Etudiant>> _etudiantsFuture;
  String _requeteRecherche = '';

  @override
  void initState() {
    super.initState();
    _etudiantsFuture = _service.getEtudiants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _rafraichir() {
    setState(() {
      _etudiantsFuture = _service.getEtudiants();
    });
  }

  List<Etudiant> _filtrerEtudiants(List<Etudiant> source) {
    final query = _requeteRecherche.trim().toLowerCase();
    if (query.isEmpty) return source;

    return source.where((e) {
      final idStr = e.id?.toString().toLowerCase() ?? '';
      final nom = e.nom.toLowerCase();
      final postnom = e.postnom.toLowerCase();
      final prenom = e.prenom.toLowerCase();
      final adresse = e.adresse.toLowerCase();
      final telephone = e.telephone.toLowerCase();

      return idStr.contains(query) ||
          nom.contains(query) ||
          postnom.contains(query) ||
          prenom.contains(query) ||
          adresse.contains(query) ||
          telephone.contains(query);
    }).toList();
  }

  Future<void> _afficherDetailsEtudiant(Etudiant etudiant) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Détails de l\'étudiant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID : ${etudiant.id ?? '-'}'),
              const SizedBox(height: 6),
              Text('Nom : ${etudiant.nom}'),
              const SizedBox(height: 6),
              Text('Postnom : ${etudiant.postnom}'),
              const SizedBox(height: 6),
              Text('Prénom : ${etudiant.prenom}'),
              const SizedBox(height: 6),
              Text('Adresse : ${etudiant.adresse}'),
              const SizedBox(height: 6),
              Text('Téléphone : ${etudiant.telephone}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fermer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _ouvrirFormulaireEtudiant(existant: etudiant);
              },
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _ouvrirFormulaireEtudiant({Etudiant? existant}) async {
    final estModification = existant != null;
    final formKey = GlobalKey<FormState>();
    final nomController = TextEditingController(text: existant?.nom ?? '');
    final postnomController = TextEditingController(text: existant?.postnom ?? '');
    final prenomController = TextEditingController(text: existant?.prenom ?? '');
    final adresseController = TextEditingController(text: existant?.adresse ?? '');
    final telephoneController = TextEditingController(text: existant?.telephone ?? '');
    bool enCours = false;

    final sauvegarde = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(estModification ? 'Modifier étudiant' : 'Nouvel étudiant'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nomController,
                        decoration: const InputDecoration(labelText: 'Nom'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                      ),
                      TextFormField(
                        controller: postnomController,
                        decoration: const InputDecoration(labelText: 'Postnom'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Postnom requis'
                            : null,
                      ),
                      TextFormField(
                        controller: prenomController,
                        decoration: const InputDecoration(labelText: 'Prénom'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Prénom requis'
                            : null,
                      ),
                      TextFormField(
                        controller: adresseController,
                        decoration: const InputDecoration(labelText: 'Adresse'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Adresse requise'
                            : null,
                      ),
                      TextFormField(
                        controller: telephoneController,
                        decoration: const InputDecoration(labelText: 'Téléphone'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Téléphone requis'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      enCours ? null : () => Navigator.pop(dialogContext, false),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: enCours
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => enCours = true);
                          try {
                            if (estModification && existant.id != null) {
                              await _service.updateEtudiant(
                                id: existant.id!,
                                nom: nomController.text.trim(),
                                postnom: postnomController.text.trim(),
                                prenom: prenomController.text.trim(),
                                adresse: adresseController.text.trim(),
                                telephone: telephoneController.text.trim(),
                              );
                            } else {
                              await _service.createEtudiant(
                                nom: nomController.text.trim(),
                                postnom: postnomController.text.trim(),
                                prenom: prenomController.text.trim(),
                                adresse: adresseController.text.trim(),
                                telephone: telephoneController.text.trim(),
                              );
                            }
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext, true);
                            }
                          } catch (e) {
                            setDialogState(() => enCours = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur : $e')),
                              );
                            }
                          }
                        },
                  child: enCours
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(estModification ? 'Mettre à jour' : 'Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );

    nomController.dispose();
    postnomController.dispose();
    prenomController.dispose();
    adresseController.dispose();
    telephoneController.dispose();

    if (sauvegarde == true) {
      _rafraichir();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              estModification
                  ? 'Étudiant modifié avec succès.'
                  : 'Étudiant ajouté avec succès.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _confirmerSuppression(Etudiant etudiant) async {
    if (etudiant.id == null) return;

    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer ${etudiant.nom} ${etudiant.postnom} ${etudiant.prenom} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirme == true) {
      try {
        await _service.deleteEtudiant(etudiant.id!);
        _rafraichir();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Étudiant supprimé avec succès.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Étudiants (API locale)'),
        actions: [
          IconButton(
            onPressed: _rafraichir,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _ouvrirFormulaireEtudiant(),
        tooltip: 'Ajouter un étudiant',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Etudiant>>(
        future: _etudiantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Erreur : ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _rafraichir,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final tousLesEtudiants = snapshot.data ?? [];
          final etudiantsFiltres = _filtrerEtudiants(tousLesEtudiants);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _requeteRecherche = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText:
                        'Rechercher par nom, postnom, prénom, adresse ou téléphone...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _requeteRecherche.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Effacer la recherche',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _requeteRecherche = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: etudiantsFiltres.isEmpty
                    ? Center(
                        child: Text(
                          _requeteRecherche.isEmpty
                              ? 'Aucun étudiant trouvé.'
                              : 'Aucun résultat pour "$_requeteRecherche".',
                        ),
                      )
                    : ListView.separated(
                        itemCount: etudiantsFiltres.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final e = etudiantsFiltres[index];
                          return ListTile(
                            onTap: () => _afficherDetailsEtudiant(e),
                            leading: CircleAvatar(
                              child: Text(e.id?.toString() ?? '${index + 1}'),
                            ),
                            title: Text('${e.nom} ${e.postnom} ${e.prenom}'),
                            subtitle: Text(
                              'Adresse : ${e.adresse} • Tél : ${e.telephone}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  tooltip: 'Modifier',
                                  onPressed: () =>
                                      _ouvrirFormulaireEtudiant(existant: e),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Supprimer',
                                  onPressed: () => _confirmerSuppression(e),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _service = EtudiantService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez saisir votre email et votre mot de passe.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (result is Map && result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const EtudiantListPage(),
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              result['message']?.toString() ?? 'Identifiants incorrects.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur réseau : $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Authentification',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Se connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}