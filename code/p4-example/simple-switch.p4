// Biblioteca `core`, para as definicoes `packet_in` e `packet_out`
#include <core.p4>

/* Portas sao representadas por um vetor de bits de tamanho 4 */
typedef bit<4> PortId;

/* Somente 8 portas sao reais, 4w8 representa o numer 8 em 4 bits */
const PortId REAL_PORT_COUNT = 4w8;

/* Estrutura de metadado que acompanha o pacote de entrada */
struct InControl {
    PortId inputPort;
}

/* Estrutura de metadado computada para pacotes de saida */
struct OutControl {
    PortId outputPort;
}

/* Portas de entrada especiais */
const PortId RECIRCULATE_IN_PORT = 0xD;
const PortId CPU_IN_PORT = 0xE;

/* Portas de saida especiais */
const PortId DROP_PORT = 0xF;
const PortId CPU_OUT_PORT = 0xE;
const PortId RECIRCULATE_OUT_PORT = 0xD;

/* Prototipos */

/**
  * Parser programavel
  * @param <H> tipo do cabecalho
  * @param b input packet
  * @param parsedHeaders, construidos pelo parser
  */
parser Parser<H>(packet_in b, out H parsedHeaders);

/**
  * Fluxo para tabela match+action
  * @param <H> tipo do cabecalho de entrada e saida
  * @param headers, cabecalhos recebidos pelo parser e enviados para deparser
  * @param parseError, erros ocorridos durante o parser
  * @param inCtrl, pacote de entrada junto com informacoes da arquitetura
  * @param outCtrl, pacote de saida junto com informacoes da arquitetura
  */
control Pipe<H>(inout H headers,
                in error parseError,
                in InControl inCtrl,
                out OutControl outCtrl);

/**
  * Deparser para pacote VSS (VerySimpleSwitch)
  * @param <H> tipo de cabecalhos
  * @param outputHeaders, cabecalhos de saida
  * @param b pacote de saida
  */
control Deparser<H>(inout H outputHeaders, packet_out b);

/**
  * Pacote top-level, deve ser instanciado pelo usuario,
  * Os argumentos para o pacote indicam blocos que devem ser
  * instanciados pelo usuario.
  * @param <H> cabecalho definido pelo usuario que sera processado
  */
package VSS<H>(Parser<H> p, Pipe<H> map, Deparser<H> d);

// Objetos especificos da arquitetura que podem ser instanciados
extern Checksym16 {
    // Construtor
    Checksum16();

    // Prepara unidade para computacao
    void clear();

    // Adiciona data para executar checksum
    void update<T>(in T data);

    // Remove os dados da checksum existente
    void remove<T>(in T data);

    // Obtem ultima checksum adicionada desde o ultimo clear
    bit<16> get();
}
