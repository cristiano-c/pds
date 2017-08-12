In questa cartella ci sono i programmi utente che stanno "sopra" lo strato del kernel scritti per esempio in C, ma non si devono compilare con GCC perchè il formato ELF non è conforme a quello MIPS del kernel stesso.

Quindi ci vuole la seguente procedura speciale per compilarli: http://os161.eecs.harvard.edu/resources/building.html

procedura:

bmake #compila i sorgenti utente
bmake install #installa gli eseguibili nel codice dell'OS
bmake clean #pulisce i files oggetto 
