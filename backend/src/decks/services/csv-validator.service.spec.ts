import { Test, TestingModule } from '@nestjs/testing';
import { CsvValidatorService } from './csv-validator.service';

describe('CsvValidatorService', () => {
  let service: CsvValidatorService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [CsvValidatorService],
    }).compile();

    service = module.get<CsvValidatorService>(CsvValidatorService);
  });

  describe('validateCsvContent', () => {
    it('should validate a valid CSV file', () => {
      const validCsv = `word,definition,example
perseverança,Qualidade de quem persevera,Sua perseverança o levou ao sucesso
determinação,Firmeza nas decisões,Ele mostrou determinação ao enfrentar os desafios`;

      const result = service.validateCsvContent(validCsv);
      expect(result.isValid).toBe(true);
      expect(result.errors).toHaveLength(0);
      expect(result.data).toHaveLength(2);
      expect(result.data![0]).toEqual({
        word: 'perseverança',
        definition: 'Qualidade de quem persevera',
        example: 'Sua perseverança o levou ao sucesso',
        tags: [],
      });
    });

    it('should validate CSV with tags', () => {
      const csvWithTags = `word,definition,example,tags
perseverança,Qualidade de quem persevera,Sua perseverança o levou ao sucesso,virtude,qualidade
determinação,Firmeza nas decisões,Ele mostrou determinação,atitude,comportamento`;

      const result = service.validateCsvContent(csvWithTags);
      expect(result.isValid).toBe(true);
      expect(result.data![0].tags).toEqual(['virtude', 'qualidade']);
      expect(result.data![1].tags).toEqual(['atitude', 'comportamento']);
    });

    it('should detect missing required columns', () => {
      const invalidCsv = `word,example
perseverança,Exemplo sem definição`;

      const result = service.validateCsvContent(invalidCsv);
      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('Colunas obrigatórias ausentes: definition');
    });

    it('should validate empty file', () => {
      const emptyCsv = 'word,definition,example\n';

      const result = service.validateCsvContent(emptyCsv);
      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('O arquivo está vazio');
    });

    it('should validate word length', () => {
      const longWord = 'a'.repeat(101);
      const csvWithLongWord = `word,definition,example
${longWord},Definição normal,Exemplo normal`;

      const result = service.validateCsvContent(csvWithLongWord);
      expect(result.isValid).toBe(false);
      expect(result.errors[0]).toContain('Palavra excede o limite');
    });

    it('should validate definition length', () => {
      const longDefinition = 'a'.repeat(501);
      const csvWithLongDefinition = `word,definition,example
palavra,${longDefinition},Exemplo normal`;

      const result = service.validateCsvContent(csvWithLongDefinition);
      expect(result.isValid).toBe(false);
      expect(result.errors[0]).toContain('Definição excede o limite');
    });

    it('should validate example length', () => {
      const longExample = 'a'.repeat(1001);
      const csvWithLongExample = `word,definition,example
palavra,Definição normal,${longExample}`;

      const result = service.validateCsvContent(csvWithLongExample);
      expect(result.isValid).toBe(false);
      expect(result.errors[0]).toContain('Exemplo excede o limite');
    });

    it('should handle malformed CSV', () => {
      const malformedCsv = `word,definition,example
palavra,"definição sem fechamento,exemplo`;

      const result = service.validateCsvContent(malformedCsv);
      expect(result.isValid).toBe(false);
      expect(result.errors[0]).toBe('Erro ao processar arquivo CSV');
    });
  });

  describe('validateFileFormat', () => {
    it('should accept valid CSV file format', () => {
      expect(service.validateFileFormat('deck.csv', 'text/csv')).toBe(true);
      expect(service.validateFileFormat('DECK.CSV', 'application/csv')).toBe(true);
    });

    it('should reject invalid file formats', () => {
      expect(service.validateFileFormat('deck.txt', 'text/plain')).toBe(false);
      expect(service.validateFileFormat('deck.xlsx', 'application/excel')).toBe(false);
    });

    it('should reject CSV files with invalid mime types', () => {
      expect(service.validateFileFormat('deck.csv', 'text/plain')).toBe(false);
    });
  });
});
