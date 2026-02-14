# Rapport de recherche M1

## English Learning Adventure

**Auteurs :** M'BEY Max (p2511097), ZHAO Mucong (p2208995), CHABAKA Ali (p2200473)

## Introduction

L'apprentissage de l'anglais chez les enfants de 5 à 10 ans pose une difficulté bien connue : à cet âge, l'attention fluctue vite, et les approches trop scolaires produisent rapidement de la fatigue ou du désengagement. Nous observons que, dans beaucoup d'outils numériques, les activités se limitent encore à des exercices répétitifs, avec peu d'adaptation au rythme réel de l'enfant. L'élève répond, valide, puis passe à l'item suivant, sans véritable dialogue.

Or, apprendre une langue à cet âge ne se réduit pas à mémoriser des mots. L'enfant a besoin d'un cadre rassurant, d'interactions courtes, d'encouragements fréquents et d'un sentiment de progression visible. C'est précisément sur ce point que les chatbots classiques montrent leurs limites : ils restent efficaces pour guider un scénario, mais ils peinent à reformuler, à contextualiser et à maintenir une conversation vivante sur la durée.

Notre projet, **English Learning Adventure**, part de cette tension entre structure pédagogique et souplesse interactionnelle. L'application combine un parcours progressif (modules, unités, révisions) avec un assistant conversationnel appuyé sur l'IA générative Gemini. L'objectif n'est pas de remplacer l'enseignant, mais de proposer un tuteur numérique complémentaire, disponible, bienveillant et adapté au niveau de l'enfant.

La problématique qui structure notre travail est la suivante : **comment l'IA générative, via Gemini, peut-elle transformer un chatbot classique en tuteur interactif et bienveillant pour un enfant débutant en anglais ?** Cette question implique deux exigences simultanées. D'une part, la réponse doit être techniquement fiable (latence, stabilité, cohérence). D'autre part, elle doit rester pédagogiquement maîtrisée (simplicité du langage, progression CECRL, sécurité du cadre d'usage).

Notre hypothèse est qu'une IA conversationnelle correctement contrainte par des consignes pédagogiques explicites peut améliorer la qualité de l'expérience d'apprentissage : davantage d'engagement, une meilleure tolérance à l'erreur, et des interactions plus proches d'une pratique réelle de la langue. Nous considérons toutefois les limites : dépendance réseau, variabilité des réponses générées, et nécessité de garde-fous stricts pour un public mineur.

## État de l'art

Les agents conversationnels éducatifs ont d'abord été conçus sur des approches à règles. Le cas historique d'**ELIZA** montre bien cette logique : le système reformule des patrons linguistiques sans compréhension du sens. Pour son époque, le résultat est marquant, mais l'illusion conversationnelle s'effondre dès qu'on sort des cas prévus.

Les générations suivantes ont amélioré cette base avec des systèmes de réponses prédéfinies plus riches, puis des techniques statistiques de classification d'intentions. Ces approches ont rendu les chatbots plus robustes dans des scénarios fermés (FAQ, assistance, entraînement guidé), mais elles restent coûteuses à maintenir et peu souples pour l'enseignement des langues. En pratique, dès que l'apprenant formule une réponse inattendue, la qualité de l'interaction chute.

L'arrivée des architectures neuronales, puis des **Transformers**, a constitué un changement d'échelle. Les grands modèles de langage ne se contentent plus de sélectionner une réponse : ils génèrent un texte contextualisé à partir de l'historique de dialogue et de la consigne. Cette capacité est particulièrement pertinente en éducation, car elle permet la reformulation, l'ajustement du vocabulaire et la reprise d'erreurs de manière plus naturelle.

Dans notre contexte, les modèles de type **Gemini** apportent une rupture utile sur trois dimensions. Premièrement, la compréhension contextuelle améliore la continuité pédagogique d'un échange. Deuxièmement, la souplesse de génération autorise des feedbacks différenciés selon le niveau de l'enfant. Troisièmement, l'ouverture multimodale de cette famille de modèles est prometteuse pour l'évolution future (texte, audio, visuel).

Il faut néanmoins rester prudent : un LLM n'est pas, par nature, un système éducatif fiable. Sans encadrement, il peut produire des réponses hors niveau, trop longues, voire incorrectes. La littérature récente converge donc vers une idée simple : la performance pédagogique dépend moins du modèle seul que de l'**orchestration** (prompt système, filtrage, scénarisation des tâches, supervision adulte). Notre projet s'inscrit explicitement dans cette logique de contrôle.

## Architecture technique

Le projet est développé avec **Flutter** afin de conserver une base de code unique et de cibler Android, iOS, Web, Windows, macOS et Linux. Ce choix nous permet de concentrer l'effort sur la cohérence pédagogique plutôt que sur la duplication technique entre plateformes.

L'architecture suit une séparation claire en couches :

- **Présentation** : les écrans (`menu_screen.dart`, `path_screen.dart`, `quiz_screen.dart`, `chat_screen.dart`, `progress_screen.dart`) gèrent l'interface et l'interaction utilisateur.
- **Gestion d'état** : `AppState` (Provider) centralise la progression, le profil, le chargement initial, l'accès aux services et les transitions de parcours.
- **Services métier** : `AIService` (Gemini), `AudioService` (TTS, effets sonores, réglages de voix) et `StorageService` (persistance locale via SharedPreferences).
- **Modèles** : `LearningPath`, `Question`, `UserProgress`, `UserProfile` structurent les données d'apprentissage et la logique de progression.

L'intégration de Gemini est encapsulée dans `AIService`, via des appels HTTP REST au modèle `gemini-2.0-flash-lite`. Ce service évite de disperser les appels API dans les écrans et facilite les évolutions futures (changement de modèle, ajout de filtrage, instrumentation des erreurs). La méthode interne `_ask` gère les échanges multi-tours, la configuration de génération et les retours de secours en cas d'échec réseau.

Le point clé est le **system prompt** : il impose un rôle conversationnel (ami/tuteur), des contraintes de longueur (réponses courtes), et surtout une adaptation au niveau CECRL. Dans `chat`, la fonction `_getLevelGuidance` définit des garde-fous explicites pour A1 et A2 (lexique simple, phrases courtes, grammaire limitée, répétition). Nous avons ainsi un compromis entre créativité du modèle et contrôle didactique.

Ce découpage en couches améliore la lisibilité du code et réduit les couplages. En revanche, il reste une limite d'architecture importante : la clé d'accès Gemini est injectée côté client (`--dart-define`). Pour un déploiement production à grande échelle, un proxy backend serait préférable afin de mieux protéger les secrets et de maîtriser les coûts d'API.

## Approche pédagogique et gamification

Le parcours d'apprentissage est organisé en **6 modules thématiques** progressifs : **First Words (salutations/politesse), Colors, Numbers, Animals, Food & Drinks, My Body**. Chaque module comprend des unités standard et une unité de révision, avec montée graduelle de difficulté (A1- à A2+).

Au-delà du QCM classique, les activités combinent plusieurs formats : compréhension orale, dictée courte, phrase à trous, mini-conversation, ordre des mots, association de paires FR/EN et expression orale guidée. Cette variété limite la monotonie et active des compétences complémentaires (réception, production, mémorisation contextuelle).

La gamification est structurée autour de mécanismes simples, lisibles par un enfant :

- **Points** (progression immédiate après les réponses),
- **Niveaux** (déblocage progressif),
- **Séries journalières** (incitation à la régularité),
- **Succès** (jalons de reconnaissance).

D'un point de vue théorique, ces choix s'alignent avec les travaux sur l'engagement :

- la **théorie de l'autodétermination** (sentiment de compétence grâce aux feedbacks rapides, autonomie via navigation guidée),
- le **renforcement positif** (récompenses fréquentes et explicites),
- la logique de **flow** (défi progressif, objectifs courts, retour immédiat).

Nous avons également intégré un test de positionnement initial, afin d'éviter l'effet démotivant d'un parcours trop facile ou trop difficile. Le placement ajuste le niveau de départ et peut ignorer certaines unités déjà maîtrisées. Cette adaptation initiale améliore la pertinence pédagogique perçue dès les premières sessions.

## Analyse des résultats

Les tests fonctionnels réalisés sur l'application montrent une base technique globalement stable : navigation fluide, chargement rapide de l'interface, sauvegarde persistante, et comportement cohérent des modules. D'après nos validations internes, l'objectif de fluidité visuelle (jusqu'à **60 FPS** sur les écrans principaux) est atteint sur les environnements de test utilisés.

Sur la partie IA, les temps de réponse observés restent compatibles avec un usage enfant (ordre de grandeur inférieur à quelques secondes). Ce point est central : au-delà de 3 à 4 secondes, l'enfant décroche rapidement. Le système conserve donc une interaction suffisamment réactive pour maintenir la dynamique de dialogue.

Sur le plan pédagogique, les retours qualitatifs sont encourageants : la combinaison « parcours + chat + feedbacks » soutient l'engagement, notamment grâce aux séries et à la visualisation des progrès. Le fait que le chatbot reformule avec un vocabulaire simple réduit la frustration en cas d'erreur.

Nous identifions cependant plusieurs limites :

- l'évaluation de la prononciation reste **incomplète** ; malgré un support de parole, nous ne disposons pas encore d'un module robuste de scoring phonétique,
- la qualité des réponses IA dépend du réseau et de la disponibilité API,
- l'évaluation empirique reste à petite échelle et doit être consolidée par une étude utilisateur plus large.

Sur les enjeux éthiques, nous avons privilégié une approche sobre : la progression et le profil sont stockés localement via SharedPreferences, ce qui limite l'exposition de données personnelles côté serveur. Néanmoins, les requêtes conversationnelles envoyées au service Gemini exigent une information claire des responsables légaux, une politique de minimisation des données et un cadre d'usage explicite.

## Conclusion

**English Learning Adventure** montre qu'un chatbot éducatif peut gagner en valeur pédagogique lorsqu'il combine une structure d'apprentissage claire et une IA générative encadrée. L'apport principal du projet ne réside pas seulement dans la génération de texte, mais dans l'articulation entre progression CECRL, interaction bienveillante et mécanismes de motivation adaptés aux enfants.

Notre contribution est double :

- une implémentation technique multiplateforme cohérente, basée sur Flutter, Provider et des services spécialisés ;
- une proposition pédagogique où Gemini agit comme tuteur conversationnel contraint, et non comme générateur libre sans contrôle.

Pour la suite, plusieurs pistes sont prioritaires :

1. **Mode multijoueur coopératif** pour pratiquer des micro-dialogues entre enfants.
2. **Tableau de bord parents/enseignants** avec indicateurs de progression et recommandations ciblées.
3. **Évaluation de prononciation** plus fine (scoring phonétique, feedback articulatoire).
4. **Proxy backend sécurisé** pour la gestion des clés API et la gouvernance des données.
5. **Étude expérimentale élargie** (protocole, groupe témoin, métriques d'apprentissage).

En l'état, le projet constitue une base crédible de tuteur numérique pour l'anglais débutant, avec une marge d'amélioration clairement identifiée pour passer d'un prototype robuste à un dispositif éducatif pleinement validé.
