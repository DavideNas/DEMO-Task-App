import os

def scrape_flutter_project(root_dir='lib', output_file='full_code.txt'):
    # Estensioni che vogliamo includere (puoi aggiungere .yaml se vuoi anche pubspec)
    valid_extensions = ('.dart')
    
    # Cartelle da ignorare (opzionale, es. icone generate o file specifici)
    ignored_dirs = {'generated', '.git'}

    with open(output_file, 'w', encoding='utf-8') as f_out:
        # Camminiamo attraverso la directory
        for root, dirs, files in os.walk(root_dir):
            # Filtriamo le cartelle ignorate
            dirs[:] = [d for d in dirs if d not in ignored_dirs]
            
            # Ordiniamo i file per un output prevedibile
            files.sort()
            
            for file in files:
                if file.endswith(valid_extensions):
                    file_path = os.path.join(root, file)
                    
                    # Normalizziamo il path per usare lo slash (stile Unix/Web)
                    display_path = file_path.replace(os.sep, '/')
                    
                    try:
                        with open(file_path, 'r', encoding='utf-8') as f_in:
                            content = f_in.read()
                            
                            # Scrittura nel file di output con il formato richiesto
                            f_out.write(f"→ {display_path}\n")
                            f_out.write("```dart\n")
                            f_out.write(content)
                            f_out.write("\n```\n\n")
                            f_out.write("---\n") # Separatore tra file
                            
                        print(f"Aggiunto: {display_path}")
                    except Exception as e:
                        print(f"Errore nella lettura di {display_path}: {e}")

if __name__ == "__main__":
    # Assicurati di eseguire lo script dalla root del progetto Flutter
    # o cambia 'lib' con il path corretto
    scrape_flutter_project('lib')
    print("\nCompletato! Il file full_code.txt è pronto.")