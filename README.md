# Um menu em shell para listar atualizações de canais do Youtube

### Desafio proposto no grupo telegram [@BashBR](https://t.me/bashbr) e comunidade [@debxp](https://t.me/debxpcomunidade)

Neste desafio de nível intermediário, nós queremos criar um menu em shell para capturar e listar as últimas atualizações de alguns canais do Youtube. Com um dos vídeos selecionado pelo utilizador, o link deve ser passado como argumento de um player, como o MPV, o VLC ou outro capaz de fazer a exibição.

Este desafio envolve a criação de uma interface com menus que devem atender às seguintes exigências:

* O primeiro menu apresentado deve ser o da seleção de canais;
* Selecionado o canal, abre-se um segundo menu com as **últimas 5** atualizações do canal;
* Selecionada a opção do vídeo, abre-se o player e o programa é _encerrado_ (importante);
* Chamar o programa passando o nome do canal como argumento faz com que apenas o segundo menu seja exibido.

## Ferramentas permitidas:

* Apenas `sed`, `awk`, `date`, `grep`, `head`, `tail`, `wget` e qualquer **comando interno** do Bash;
* O player é da escolha de cada um, mas os testes serão com o MPV;

## Outros requisitos:

* Registro de canais em arquivo separado (chamado de `sources`) na _mesma pasta_ do script;
* Tratamento de erros com mensagens significativas enviadas para `stderr`;
* Strings das mensagens de erro separadas do código que exibe os erros;
* Avisos (*warnings*) não devem ser tratados como erros fatais;
* Erros fatais devem causar a saída do programa com status diferente de zero (`0`);

## Informação importante!

O RSS dos canais do Youtube segue este modelo:

```
https://www.youtube.com/feeds/videos.xml?channel_id=ID_DO_CANAL
```

Por exemplo:

```
# Curso GNU
https://www.youtube.com/feeds/videos.xml?channel_id=UCQTTe8puVKqurziI6Do-H-Q

# debxp
https://www.youtube.com/feeds/videos.xml?channel_id=UC8EGrwe_DXSzrCQclf_pv9g
```

## Apresentação das submissões:

Enviar o link do gist/snippet (ou serviço semelhante) contendo o script e uma explicação detalhada de seu funcionamento até quinta-feira, 8 de abril, para blau@debxp.org.

## Prêmio:

Como sempre, o aprimoramento das nossas habilidades como programadores e do nosso entendimento do shell! ;-)
