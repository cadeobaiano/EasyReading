import { Injectable } from '@nestjs/common';
import { parse } from 'papaparse';

export interface CsvValidationResult {
  isValid: boolean;
  errors: string[];
  data?: any[];
}

@Injectable()
export class CsvValidatorService {
  private readonly requiredColumns = ['word', 'definition', 'example'];
  private readonly maxRowLength = 1000;
  private readonly maxWordLength = 100;
  private readonly maxDefinitionLength = 500;
  private readonly maxExampleLength = 1000;

  /**
   * Valida o conteúdo de um arquivo CSV
   */
  validateCsvContent(csvContent: string): CsvValidationResult {
    const errors: string[] = [];
    let parsedData: any[] = [];

    // Parse do CSV
    const parseResult = parse(csvContent, {
      header: true,
      skipEmptyLines: true,
      transform: (value) => value.trim(),
    });

    // Verifica erros de parse
    if (parseResult.errors.length > 0) {
      errors.push('Erro ao processar arquivo CSV');
      parseResult.errors.forEach((error) => {
        errors.push(`Linha ${error.row + 1}: ${error.message}`);
      });
      return { isValid: false, errors };
    }

    // Valida colunas obrigatórias
    const headers = parseResult.meta.fields || [];
    const missingColumns = this.requiredColumns.filter(
      (col) => !headers.includes(col),
    );

    if (missingColumns.length > 0) {
      errors.push(
        `Colunas obrigatórias ausentes: ${missingColumns.join(', ')}`,
      );
      return { isValid: false, errors };
    }

    // Valida número de linhas
    if (parseResult.data.length === 0) {
      errors.push('O arquivo está vazio');
      return { isValid: false, errors };
    }

    if (parseResult.data.length > this.maxRowLength) {
      errors.push(
        `Número máximo de linhas excedido (máximo: ${this.maxRowLength})`,
      );
      return { isValid: false, errors };
    }

    // Valida cada linha
    parsedData = parseResult.data.map((row: any, index: number) => {
      const rowErrors: string[] = [];
      const rowNumber = index + 1;

      // Valida palavra
      if (!row.word) {
        rowErrors.push(`Linha ${rowNumber}: Palavra é obrigatória`);
      } else if (row.word.length > this.maxWordLength) {
        rowErrors.push(
          `Linha ${rowNumber}: Palavra excede o limite de ${this.maxWordLength} caracteres`,
        );
      }

      // Valida definição
      if (!row.definition) {
        rowErrors.push(`Linha ${rowNumber}: Definição é obrigatória`);
      } else if (row.definition.length > this.maxDefinitionLength) {
        rowErrors.push(
          `Linha ${rowNumber}: Definição excede o limite de ${this.maxDefinitionLength} caracteres`,
        );
      }

      // Valida exemplo
      if (row.example && row.example.length > this.maxExampleLength) {
        rowErrors.push(
          `Linha ${rowNumber}: Exemplo excede o limite de ${this.maxExampleLength} caracteres`,
        );
      }

      // Adiciona erros encontrados
      errors.push(...rowErrors);

      return {
        word: row.word,
        definition: row.definition,
        example: row.example || '',
        tags: row.tags ? row.tags.split(',').map((tag: string) => tag.trim()) : [],
      };
    });

    return {
      isValid: errors.length === 0,
      errors,
      data: errors.length === 0 ? parsedData : undefined,
    };
  }

  /**
   * Valida o formato do arquivo
   */
  validateFileFormat(filename: string, mimeType: string): boolean {
    const validExtensions = ['.csv'];
    const validMimeTypes = ['text/csv', 'application/csv'];

    const extension = filename.toLowerCase().slice(filename.lastIndexOf('.'));
    return (
      validExtensions.includes(extension) && validMimeTypes.includes(mimeType)
    );
  }
}
