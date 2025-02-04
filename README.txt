## Roteiro de instalação e configuração

Este roteiro guiará você através do processo de configuração do ambiente de simulação e execução do projeto do relógio digital utilizando o SimulIDE e o AVRA em um sistema Linux.

### Requisitos de Software

- SimulIDE (versão 0.4.15 ou superior)
- AVRA (Assembler for Atmel AVR microcontrollers)
- Editor de texto

### Passos de Instalação

1. **Instalar o SimulIDE:**
   ```
   sudo add-apt-repository ppa:simulide/simulide
   sudo apt update
   sudo apt install simulide
   ```

2. **Instalar o AVRA:**
   ```
   sudo apt-get install avra
   ```

### Configuração do Projeto

1. Abra um terminal e clone o repositório do projeto:
   ```
   git clone https://github.com/mpsfranca/PSB
   cd PSB
   ```
2. Verifique se o arquivo principal do projeto é `main.asm`.
3. Localize o arquivo do circuito SimulIDE (`.sim1`) no diretório do projeto.

### Compilação

1. No terminal, navegue até o diretório do projeto.
2. Execute o seguinte comando para compilar usando o AVRA:
   ```
   avra main.asm
   ```
3. Este comando irá gerar um arquivo `main.hex` se a compilação for bem-sucedida.

### Simulação no SimulIDE

1. Abra o SimulIDE a partir do terminal ou menu de aplicativos.
2. No SimulIDE, vá para `File > Open Circuit` e selecione o arquivo `.sim1` do projeto.
3. Localize o componente do microcontrolador ATmega328P no circuito.
4. Clique com o botão direito no microcontrolador e selecione "Load firmware".
5. Navegue até o diretório do projeto e selecione o arquivo `main.hex` gerado na etapa de compilação.
6. Inicie a simulação clicando no botão "Play" no SimulIDE.

### Execução e Teste

1. Após iniciar a simulação, observe se o programa está executando corretamente no ATmega328P virtual.
2. Verifique se os displays estão mostrando o tempo corretamente na simulação.
3. Teste as funcionalidades usando os botões virtuais conforme descrito na documentação do projeto.
