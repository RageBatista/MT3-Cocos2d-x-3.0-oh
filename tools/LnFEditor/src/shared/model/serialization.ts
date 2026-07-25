/** 格式保持节点 — 在 AST 中嵌入原始格式信息 */
export interface FormatPreservingNode {
  leadingComments?: string[];
  trailingComments?: string[];
  indent?: string;
  attributeOrder?: string[];
  selfClosing?: boolean;
  rawAttributes?: Map<string, string>;
  rawContent?: string;
}

/** 带格式信息的 WidgetLook */
export interface FormattedWidgetLook {
  data: import('./types').WidgetLook;
  format: FormatPreservingNode;
  childFormats: Map<string, FormatPreservingNode>;
  sectionFormats: Map<string, FormatPreservingNode>;
  stateFormats: Map<string, FormatPreservingNode>;
}

/** 序列化选项 */
export interface SerializationOptions {
  preserveIndent: boolean;
  preserveComments: boolean;
  preserveAttributeOrder: boolean;
  preserveBlankLines: boolean;
  encoding: 'utf-8' | 'utf-8-bom';
  indentString: string;
}

/** 默认序列化选项 */
export const DEFAULT_SERIALIZATION_OPTIONS: SerializationOptions = {
  preserveIndent: true,
  preserveComments: true,
  preserveAttributeOrder: true,
  preserveBlankLines: true,
  encoding: 'utf-8',
  indentString: '    ',
};
