/*
 * Copyright(C) 1999-2020, 2022, 2023 National Technology & Engineering Solutions
 * of Sandia, LLC (NTESS).  Under the terms of Contract DE-NA0003525 with
 * NTESS, the U.S. Government retains certain rights in this software.
 *
 * See packages/seacas/LICENSE for details
 */
#ifndef APR_SCANNER_H
#define APR_SCANNER_H

// Flex expects the signature of yylex to be defined in the macro YY_DECL, and
// the C++ parser expects it to be declared. We can factor both as follows.

#undef YY_DECL
#define YY_DECL SEAMS::Parser::token_type SEAMS::Scanner::lex(SEAMS::Parser::semantic_type *yylval)

#ifndef __FLEX_LEXER_H
#define yyFlexLexer SEAMSFlexLexer
#include "FlexLexer.h"
#undef yyFlexLexer
#endif

#include <iostream>

namespace SEAMS {

  /** Scanner is a derived class to add some extra function to the scanner
   * class. Flex itself creates a class named yyFlexLexer, which is renamed using
   * macros to SEAMSFlexLexer. However we change the context of the generated
   * yylex() function to be contained within the Scanner class. This is required
   * because the yylex() defined in SEAMSFlexLexer has no parameters. */
  class Aprepro;
  class Scanner : public SEAMSFlexLexer
  {
  public:
    friend class Parser;

    /** Create a new scanner object. The streams arg_yyin and arg_yyout default
     * to cin and cout, but that assignment is only made when initializing in
     * yylex(). */
    explicit Scanner(Aprepro &aprepro_yyarg, std::istream *in = nullptr,
                     std::ostream *out = nullptr);
    /** Required for virtual functions */
    ~Scanner() override;

    bool add_include_file(const std::string &filename, bool must_exist);
    int  yywrap() override;
    void yyerror(const char *s);
    void LexerOutput(const char *buf, int size) override;
    int  LexerInput(char *buf, int max_size) override;

    /** This is the main lexing function. It is generated by flex according to
     * the macro declaration YY_DECL above. The generated bison parser then
     * calls this virtual function to fetch new tokens. */
    virtual Parser::token_type lex(Parser::semantic_type *yylval);

    char *rescan(char *string);
    char *execute(char *string);
    char *import_handler(char *string);
    char *if_handler(double x);
    char *elseif_handler(double x);
    char *switch_handler(double x);
    char *case_handler(double x);

    /** Enable debug output (via arg_yyout) if compiled into the scanner. */
    void set_debug(bool b);

    /* User arguments.  */
    class Aprepro &aprepro;

    /* save the original string for substitution history */
    void save_history_string();
  };

} // namespace SEAMS

#endif // APR_SCANNER_H
