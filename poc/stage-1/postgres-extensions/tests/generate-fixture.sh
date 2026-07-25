#!/bin/sh
set -eu

output=${1:-/tmp/sec-fixture.jsonl}
seed=20260725

awk -v seed="${seed}" 'BEGIN {
  tickers[0] = "ALFA"; companies[0] = "Alpha Holdings";
  tickers[1] = "BETA"; companies[1] = "Beta Systems";
  tickers[2] = "GAMM"; companies[2] = "Gamma Energy";
  tickers[3] = "DELT"; companies[3] = "Delta Retail";
  forms[0] = "10-K"; forms[1] = "10-Q";
  items[0] = "Item 7"; items[1] = "Item 8";
  titles[0] = "Management Discussion and Analysis";
  titles[1] = "Financial Statements and Supplementary Data";
  texts[0] = "Revenue recognition depends on transfer of control. Liquidity remains strong despite market volatility.";
  texts[1] = "The company recognizes sales when control passes to the customer. Cash resources support operations.";
  texts[2] = "Capital expenditures increased for data center capacity and efficient computing infrastructure.";
  texts[3] = "Cybersecurity risk and supply-chain constraints may affect operating results.";
  texts[4] = "Operating cash flow funded investment while foreign-exchange movements affected reported revenue.";
  texts[5] = "Artificial intelligence services increased demand; management monitors customer adoption.";
  texts[6] = "The registrant recorded restructuring charges and expects cost savings in future periods.";
  texts[7] = "Gross margin changed because of product mix, pricing, and input costs.";
  texts[8] = "A repeated-looking passage tests stable identifiers — punctuation, Unicode, and café text.";
  texts[9] = "Debt maturities and covenant compliance are monitored through treasury controls.";

  for (i = 1; i <= 120; i++) {
    company = (i - 1) % 4;
    form = (i - 1) % 2;
    item = (i - 1) % 2;
    text = (i - 1) % 10;
    year = 2022 + ((i - 1) % 3);
    month = 1 + ((i * 7 + seed) % 12);
    day = 1 + ((i * 11 + seed) % 27);
    quarter = form == 0 ? "null" : (((i - 1) % 3) + 1);
    v1 = ((i * 17 + seed) % 101) / 100.0;
    v2 = ((i * 29 + seed) % 101) / 100.0;
    v3 = ((i * 43 + seed) % 101) / 100.0;
    printf("{\"chunk_id\":\"fixture-%03d\",\"ticker\":\"%s\",\"cik\":\"%010d\",\"company_name\":\"%s\",\"form\":\"%s\",\"filing_date\":\"%04d-%02d-%02d\",\"fiscal_year\":%d,\"quarter\":%s,\"reporting_period\":\"%04d-12-31\",\"accession_number\":\"%010d-%02d-%06d\",\"source_url\":\"fixture://stage-1/%03d\",\"item_number\":\"%s\",\"canonical_section_title\":\"%s\",\"observed_section_title\":\"%s\",\"display_section_title\":\"%s\",\"corpus_build_id\":\"arm64-poc-v1\",\"chunk_set_id\":\"seed-%d\",\"source_text\":\"%s\",\"embedding\":\"[%.2f,%.2f,%.2f]\"}\n",
      i, tickers[company], 1000000 + company, companies[company], forms[form],
      year, month, day, year, quarter, year, 1000000 + company, year % 100, i,
      i, items[item], titles[item], titles[item], titles[item], seed, texts[text],
      v1, v2, v3);
  }
}' > "${output}"

test "$(wc -l < "${output}" | tr -d " ")" = "120"
sha256sum "${output}"
