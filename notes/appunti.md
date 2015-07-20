# Appunti

E' buona pratica mettere le espressioni nei binding all'interno dei template html? 

Il testing impone di utilizzare dei nomi ben definiti per selezionare gli elementi per
i test e2e... quando i nomi cambiano, abbiamo il problema che i test non passano.

E' buona convenzione quindi determinare by design il nome da dare a variabili e stabilire
delle convenzioni, anche per garantire una certa coerenza nei nomi delle variabili all'interno
de progetto.

Protractor oltre a svolgere le normali funzioni di automazione del browser permette ad esempio
di trovare gli elementi del dom in base al nome delle variabili che hanno nei binding.

Inoltre consente di trovare tutti gli elementi che vengono generati dalla direttiva ng-repeat.

I test end-to-end di solito non vengono lanciati nelle macchine degli sviluppatori perche' richiedono
l'installazione e configurazione dei framework per i browser tests (quali Protractor Selenium ecc...).

Tramite l'approccio a container possiamo automatizzare il processo di installazione e configurazione
di questi ambienti per diversi sistemi operativi, e quindi far girare i test end-to-end anche nelle
macchine degli sviluppatori. (Docker VS Vagrant)
