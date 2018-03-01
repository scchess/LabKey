/*
 * Copyright (c) 2012 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


--new drug resistance mutation.  delete previous in case
DELETE from sequenceanalysis.drug_resistance WHERE
ref_nt_id = 5 AND
ref_aa_id = 105 and
class = 'NRTI' AND
aa_position = 138
;

INSERT INTO sequenceanalysis.drug_resistance (ref_nt_id, ref_aa_id, class, aa_position, aa_insert_index, reference_aa, mutant_aa, drug) VALUES
(5, 105, 'NRTI', 138, 0, 'E', 'K', 'NVP');
INSERT INTO sequenceanalysis.drug_resistance (ref_nt_id, ref_aa_id, class, aa_position, aa_insert_index, reference_aa, mutant_aa, drug) VALUES
(5, 105, 'NRTI', 138, 0, 'E', 'K', 'EFV');
INSERT INTO sequenceanalysis.drug_resistance (ref_nt_id, ref_aa_id, class, aa_position, aa_insert_index, reference_aa, mutant_aa, drug) VALUES
(5, 105, 'NRTI', 138, 0, 'E', 'K', 'ETR');
INSERT INTO sequenceanalysis.drug_resistance (ref_nt_id, ref_aa_id, class, aa_position, aa_insert_index, reference_aa, mutant_aa, drug) VALUES
(5, 105, 'NRTI', 138, 0, 'E', 'K', 'RPV');

--insert new ref strains
delete from sequenceanalysis.virus_strains where virus_strain ='GHNJ196';
insert into sequenceanalysis.virus_strains (virus_strain,genbank,species) values ('GHNJ196', 'AB231898', 'HIV');

delete from sequenceanalysis.ref_nt_sequences where name ='GHNJ196';
insert into sequenceanalysis.ref_nt_sequences (name,category,subset,mol_type,species,genbank,sequence) values
('GHNJ196', 'Virus', 'GHNJ196', 'RNA', 'HIV', 'AB231898', 'TGGATGGGCTAATTTACTCCAAGAAAAGACAGGAGATCCTTGATCTGTGGGTCTATCACACACAAGGATTCTTCCCAGATTGGCAGAACTACACACCAGGGCCAGGGATCAGATACCCACTGACCTTTGGATGGTGCTTCAAACTAGTACCAATAGATCCAGCAGAGGTAGAGGAAGCCAATGAAGGAGAGAACAACGTCTTATTACACCCCATCTGCCAGCATGGAATGGATGATGAAGACAGAGAAGTACTGGTCTGGAAGTTTGACAGCCGCCTGGCATTCACACACACAGCAAGAGAGCTGCATCCGGAGTTTTACAAAGACTGTTGACACAGAAGTTGCTGACAGGGACTTTCTGCCTGGGACTTTCCGCTGGGGACTTTCCAGGGAGGTGTGGTGTGGGAGGAGTTGGGGAGTGGCTAACCCTCAGATGCTGCATATAAGCAGCCGCTTCTCGCCTGTACTGGGTCTCTCTTGCTAGACCAGATTTGAGCCTGGGAGCTCTCTGACTAGCAGGGAACCCACTGCTTAAGCCTCAATAAAGCTTGCCTTGAGTGCTCTAAGTAGTGTGTGCCCGTCTGTTGTGTGACTCTGGTAACTAGAGATCCCTCAGACCAATTTAGTCTTGGTAAAAATCTCTAGCAGTGGCGCCCGAACAGGGACCGGAAGTTAATAGGGACGCGAAAGCGAAAGTTCCAGAGAAGTATCTCGACGCACGGACTCGGCTTGCTGAGGTGCACACAGCAAGAGGCGAGAGCGGCGACTGGTGAGTACGCCAATTTTTGACTAGCGGAGGCTAGAAGGAGAGAGATGGGTGCGAGAGCGTCAGTATTAAGTGGGGGAAAATTAGATGCATGGGAGAAAATTCGGTTGCGGCCAGGGGGAAAGAAACAGTATAAACTAAAACATATAGTATGGGCAAGCAGGGAGCTGGAAAGATTCGCTCTTAACCCTGGCCTTTTAGAAACAGCAGAAGGATGTCAACAGCTATTGGAACAGTTACAATCAACTCTCAGGACAGGATCAGAGGAACTTAAATCCTTATATAATACAATAGCAACCCTTTGGTGCGTACATCAAAGGATAGACATAAGAGACACCAAGGAAGCCTTAGATAAAATAGAGGAAGCTCAAAATAAGAGCAAACAAAAGACACAGCAGGCAGCAGCTGCCACAGGAAGCAGCAACCAAGTAAGAGTCAGCAGCCAAAATTTCCCTATAGTGCAAAATGCACAAGGGCAAATGATACATCAGTCCATGTCACCTAGGACTTTAAATGCATGGGTGAAGGTAATAGAAGAAAAGGGTTTCAGCCCAGAAGTAATACCCATGTTTTCAGCATTATCAGAAGGAGCCGCCCCACAAGATTTAAATATGATGCTAAACATAGTGGGGGGACATCAGGCAGCAATGCAGATGTTAAAAGATACCATCAATGAGGAAGCTGCAGAATGGGACAGAGTACATCCAGTACATGCAGGGCCTATTCCACCAGGCCAGATGAGGGAACCAAGGGGAAGTGACATAGCAGGAACTACTAGTACCCTTCAAGAACAAATAGGGTGGATGACAAGCAATCCACCTATCCCAGTGGGAGAAATTTATAAAAGATGGATAGTTCTGGGATTAAATAAAATAGTAAGAATGTATAGCCCTGTCAGCATTTTGGACATAAGACAAGGGCCAAAAGAACCCTTTAGAGATTATGTAGACAGGTTCTTTAAAACTTTAAGAGCTGAACAAGCTACACAGGATGTAAAGAACTGGATGACAGAAACCTTGCTGGTCCAAAATGCTAATCCAGACTGTAAGACCATTTTAAGAGCATTAGGACCAGGGGCTTCATTAGAAGAAATGATGACAGCATGTCAGGGAGTGGGAGGACCTAGCCATAAGGCAAGGGTTTTGGCTGAAGCAATGAGTCAAGCACAACAGTCCAATGTAATGATGCAGAGAGGCAATTTTAGGGGCCAGAGAACAATAAAGTGTTTCAACTGTGGCAAAGAAGGACACCTAGCCAGAAATTGCAAGGCCCCTAGGAAAAGGGGTTGTTGGAAGTGTGGGAAGGAAGGACACCAAATGAAAGACTGCACTGAGAGACAGGCTAATTTTTTAGGGAAAATTTGGCCTTCCAACAAGGGGAGGCCAGGAAATTTTCCTCAGAGCAGACCGGAACCATCAGCCCCACCAGCAGAGAGCTTGGGGATGGGGGAAGAGGTAGCCTCAACCCCGAAGCAGGAGCCGGGGGACAAGGGAATATATCCTCCCTTAACTTCCCTCAAATCACTCTTTGGCAACGACCCTTAGTCACAGTAAGAATAGGGTGTCAGCTAATAGAAGCCCTATTAGACACAGGAGCAGATGATACAGTATTAGAAGAAAAAGTAGAATTACCAGGAAAATGGAAACCAAAAATGATAGGGGGAATTGGAGGTTTTATCAAAGTAAGACAGTATGATCAGATACTTATAGAAATTTGTGGAAAAAGGGCCATAGGTACAGTATTAGTAGGACCTACACCTGTCAACATAATTGGAAGGAATATGTTGACTCAGATTGGCTGTACTTTAAATTTTCCAATTAGTCCTATTGAAACTGTGCCAGTAAAATTAAAGCCAGGAATGGATGGTCCAAAGGTTAAACAATGGCCATTGACAGAAGAAAAAATAAAAGCATTAACAGACATTTGTACAGAAATGGAAAAGGAAGGACAAATTTCAAAAATTGGCCCTGAAAATCCCTACAATACTCCAGTATTTGCCATAAAGAAAAAAGATAGTACTAAATGGAGAAAATTAGTAGATTTCAGAGAGCTTAATAAAAGACCTCAAGACTTCTGGGAGGTCCAATTAGGAATACCTCACCCAGCAGGATTAAAAAAGAAAAAATCAGTAACAGTACTAGATGTGGGGGATGCATATTTTTCAGTTCCCTTACATGAAGACTTTAGAAAGTATACTGCATTCACTATACCTAGTGTAAATAATGAGACACCAGGAATTAGATATCAGTACAATGTGCTTCCACAGGGATGGAAAGGATCACCAGCAATATTTCAGGCAAGCATGACAAAAATCTTAGAGCCCTTTAGAACAAACAATCCAGAAATGGTGATCTACCAATACATGGATGATTTATATGTAGGATCTGACTTAGAGATAGGGCAGCATAGAGCAAAAATAGAGGAGTTGAGAGAACATCTACTGAAATGGGGATTTACCACACCAGACAAAAAACATCAGAAGGAACCTCCATTTCTTTGGATGGGATATGAACTCCATCCTGACAAATGGACAGTCCAACATATAGAACTGCCAGAAAAAGACAGCTGGACTGTCAATGATATACAGAAATTAGTGGGAAAACTAAATTGGGCGAGTCAAATTTATCCTGGAATTAAAGTAAGGCAACTGTGTAAACTCCTCAGGGGAGCCAAAGCACTAACAGATATAGTAACACTGACTGAGGAAGCAGAATTAGAATTGGCAGAGAACAGGGAAATTCTAAAAGAACCTGTACATGGAGTCTACTATGACCCAGCAAAAGACTTAGTAGCAGAAATACAGAAACAAGGGCAAGACCAATGGACATATCAAATTTATCAGGAACCATTTAAAAATTTAAAAACAGGAAAATATGCAAAAAAGAGGTCTGCCCACACTAATGATGTAAAACAATTAACAGAGGTAGTACAAAAAGTGGCTACAGAGAGCATAATAATATGGGGAAAGACCCCTAAATTTAGACTACCCATACAAAAAGAAACATGGGAAGCATGGTGGATGGATTATTGGCAAGCTACCTGGATTCCTGAATGGGAGTTTGTCAATACCCCTCCTCTAGTAAAATTATGGTACCAATTAGAAAAAGACCCCATAGTAGGAGCAGAAACTTTCTATGTAGATGGGGCAGCAAATAGGGAGACTAAACTAGGAAAAGCAGGATATGTCACTGACAGAGGAAGACAAAAGGTGGTTTCCCTAACTGAGACAACAAATCAAAAGACTGAATTACATGCAATTCATCTAGCCTTGCAAGATTCAGGATCAGAAGTAAATATAGTAACAGACTCACAGTATGCATTAGGAATTATTCAGGCACAACCAGACAAGAGTGACTCAGAAATAGTCAATCTAATAATAGAAAAACTAATAGAAAAGGACAAAGTCTACCTGTCATGGGTACCAGCACACAAAGGGATTGGAGGAAATGAACAAGTAGATAAATTAGTCAGTAATGGAATCAGGAGAGTACTATTTTTAGATGGCATAGATAAAGCCCAAGAAGAACATGAAAGATATCATAGCAATTGGAGAGCAATGGCTAATGATTTTAATCTGCCACCTATAGTAGCAAAAGAAATAGTGGCCAGCTGTGATAAATGTCAGCTAAAAGGGGAAGCCATGCATGGACAAGTAGACTGTAGTCCAGGAATATGGCAATTAGATTGTACACATTTAGAAGGAAAAATTATCCTGGTAGCAGTCCATGTAGCCAGTGGCTACATAGAAGCAGAAGTTATCCCAGCAGAAACAGGACAGGAAACAGCATACTTTATATTAAAGTTAGCAGGAAGATGGCCAGTGAGAGTAATACACACAGACAATGGCAGCAATTTCACCAGTGCTGCAGTAAAGGCAGCATGTTGGTGGGCAGATGTCAAACAAGAATTTGGAATTCCCTACAATCCCCAAAGCCAAGGAGTAGTGGAATCTATGAATAAAGAATTAAAGAAAATTATAGGACAGGTCAGGGATCAAGCTGAGCACCTTAAGACAGCAGTACAGATGGCAGTATTCATTCACAATTTTAAAAGAAAAGGGGGGATTGGGGGGTACAGTGCAGGGGAAAGAATAATAGACATAATAGCATCAGACATACAAACTAAAGAACTACAAAAACAAATTATAAAAATTCAAAATTTTCGGGTTTATTACAGAGACAGCAGAGACCCCATTTGGAAAGGACCAGCAAAACTACTCTGGAAAGGTGAAGGGGCAGTAGTAATACAGGACAATAGTGATATAAAAGTAGTACCAAGGAGAAAAGCAAAAATCATTAAGGATTATGGAAAACAGATGGCAGGTGATGACTGTGTGGCAGGTAGACAGGATGAAGATTAGGACATGGAACAGTTTAGTAAAGCATCATATGTATGTCTCTAAGAAAGCTAAGGATTGGTTTTATAGACATCATTTTGAAAGTAGACATCCAAAAGCAAGTTCAGAAGTACACATCCCACTAGGGGATGCTAGATTAGTAGTAAGAACCTATTGGGGTTTGAATACAGGAGAAAGAGACTGGCACTTGGGTCATGGGGTCTCCATAGAATGGAGGCAGAGAAGGTATAGCACACAAATAGATCCTGACCTAGCTGACCAACTGATTCACCTGTATTATTTTGACTGTTTTTCAGAATCTGCCATAAGGAAAGTCCTATTAGGACAAGTAGTTAGACCTAGTTGTGAATATCAAGCAGGACACAGTAAGGTAGGATCGCTACAATATTTGGCACTGAAAGCATTAGTAGCACCAACAAGGAGAAAGCCACCTTTACCTAGTGTTAAGAAGTTAACAGAAGATCGATGGAACAAGCCCCAGAAGACCAGGGGCCACAGAGGGAACCGTCCAATCAATGGACACTAGAACTGTTAGAGGAGCTTAAACAAGAAGCTGTTAGACATTTTCCTAGGCCGTGGCTTCATGGATTAGGACAATATATCTATAACACATATGGGGACACTTGGGAAGGGGTTGAAGCTATAATAAGAATCTTGCAACAACTACTGTTTGTTCATTTCAGAATTGGGTGTCAACATAGCAGAATAGGCATTATTCGAGGGAGAAGAGGCAGGAATGGATCTGGTAGATCCTAACCTAGATCCATGGAACCACCCGGGAAGTCAGCCTACAACTGCTTGTAGCAAGTGTTATTGTAAAATATGCTGCTGGCATTGCCAATTGGGCTTTCTGAACAAGGGCTTAGGCATCTCCTATGGCAGGAAGAAGCGGAGACCCCGACGAGGAACTCCTCAGAACCGTCAGGATTATCAAAATCCTGCACCAAAGCAGTGAGTAGTGCTAATTAGTATATATGATGCAATCCTTAGTAATAGCTGCAATAGTAGGACTAGTAGTAGCATTCATAGCAGCCATAGTTGTGTGGACCATAGAGTATATAGAATATAGAAGAATAAGGAAACAAAAACAAATAGATAGGTTACTTGATAGAATAAGAGAAAGAGCAGAAGATAGTGGCAATGAGAGTGATGGGGACACAGAAGAATTATCCATGCTTGTGGAGGTGGGGGATTATAATCTTTTGGATAATGCTGATATGTAAGGGTGAAGATCTGTGGGTCACGGTCTATTATGGGGTACCTGTGTGGAGAGACGCAGATACCACCCTGTTTTGTGCATCAGATGCGAAATCATATGATACAGAAGTACATAATGTTTGGGCCACACATGCCTGTGTACCCACAGATCCTAGCCCACAAGAAATATATTTGGAAAATGTAACAGAAAATTTTAATATGTGGAAAAATAACATGGTAGAACAGATGCATGAAGATATAATTAGTCTATGGGACCAAAGCTTAAAACCATGTGTAGAGTTAACCCCTCTCTGCGTTACTTTAGAGTGTCATAGTGTCACCAACAGCAGTGAGAACAAAATTGGCAACATATCTATTGAAATGCAAGGGGAAATAAAAAACTGCTCTTTCAATATGACCACAGAACTACGAGACAAGAATCGGAAAATGCATGCACTTTTTTATAGACAAGATATAGTACCAATGAATGAAAGTTTAGTATCAATAAATACAACTAACAGCACTGATCAGTATAGGTTAATAAATTGTAATACCTCAACCGTTACACAGGCTTGTCCAAAGGTATCCTTTGAGCCAATTCCCATACATTATTGTGCCCCTGCTGGTTTTGCAATTCTGAAATGTAATGATAAGAATTTCAATGGAACAGGGCTATGCAGGAATGTCAGTACAGTACAATGCACACATGGAATCAAGCCAGTAGTATCAACTCAACTGCTGTTAAATGGCAGTCTAGCAGAAAGAGAGGTAGTGATTAGATCTGAAAATTTCTCAGATAATGCCAAAACCATAATAGTACAGTTAGCTAAGCCTGTACAAATTAATTGTACCAGACCTAACAACAATACAAGAACAGGTATACATATGGGACTAGGGCGAACATTCTATGCAACAGGTGACATAATAGGGGATATAAGACAAGCACATTGTAATGTTAGTGCAAAAGCTTGGAATGATACTTTACAACAGGTGGCCACACAATTAGGGAAGCACTACGGTGGTAACACAACAATCATATTTACTAACCACTCAGGAGGGGATGTAGAAATTATGACACATACTTTTAATTGTGGAGGAGAATTTTTCTATTGCAATACATCAAGACTGTTTAATAGCAATTGGAAAAACGGTACTGCCAGCTCAAATGGCACTGCAAATGACATTATAACTCTCCAATGCAGAATAAGGCAAATTATAAATATGTGGCAGAAAGTAGGAAAAGCAATGTATGCCCCTCCCATCCCAGGAGTAATAAGGTGTGAGTCAAACATTACAGGACTACTATTAACAAGAGATGGAGGGAAAAATACTAGTGGTGTAAATGAGACTTTCAGACCTGAAGGAGGAAATATGAAAGACAATTGGAGAAGTGAATTATATAAGTATAAAGTAATAAAAATTGAACCACTAGGTGTAGCACCCACCCGTGCAAGAAGAAGAGTGGTGGGAAGAGAAAAAAGAGCAATAGGTGGACTGGGAGCTGCCCTCCTTGGGTTCCTAGGAGCAGCAGGAAGCACTATGGGCGCGGCGTCAATAACGCTGACGGTACAGGCCAGACAATTATTGTCTGGTATAGTGCAACAGCAGAGCAATCTGCTGAGGGCTATAAAGGCTCAACAAGAACTGTTGAGACTCACGGTCTGGGGCATTAAACAGCTCCAGGCAAGAGTCCTGGCTCTGGAGGGATACCTAAGGGATCAGCAGCTCCTAGGAATTTGGGGATGCTCTGGAAGACTCATCTGCACCACTAATGTACCCTGGAACTCTACTTGGAGTAATAAAACTTATAATGACATATGGGGGAACATGACCTGGCTGGAATGGGATAGAGAAATTAGCAATTACACAGACATAATATATAATCTAATTGAAGTATCGCAAAACCAGCAGGAAAAGAATGAACAAGACTTATTGGCATTGGACAAGTGGGCAAGTCTGTGGAGTTGGTTTAGCATAACAAATTGGCTGTGGTATATAAAAATATTTATAATGATAGTAGGAGGCTTAATAGGTTTAAGAATAGTTTTTGCTGTACTTACTATAATAAATAGAGTTAGGCAGGGATACTCACCTTTGTCATTCCAGACCCTTACCCACCACCAGAGGGATCCAGGCAGACCAGAAAGAATCGAAGAAGAAGGTGGCGAGCAAGCCAGAGCCAGATCCGTGCGATTAGTGAGCGGCTTCTTAGCTCTTGCCTGGGACGACCTAAGGAGCCTGTGCCTCTTCAGCTACCACCGATTGAGAGACTTACTCTTGATTCTGGGACACAGCAGCCTCAAGAGCCTGCAACTGGGGTGGGAAGCCCTCAAATATCTGTGGAATCTTCTAACATACTGGGGTCAGGAACTAAGGAATAGTGCTATTAGTTTGCTTGATACCATAGCAATAGCAGTAGCTAACTGGACAGACAGAGTCATAGAAATAGGACAAAGAATTGCTAGAGCTATTTGCAACATACCTAGAAGAATCAGACAGGGTCTTGAAAGGGCTTTGATATAACATGGGCAGCAAGCTTTCAAAAAGCCGCATAGTGGGATGGGCTAGGGTTAGGGAAAGACTAAGACGAACCCCTCCAACAGCAGAAAGAGTAAGACGACCCCCTCCAGCAGCAGAAGGGGCAGGAGCAACATCTCAAGCAGCAGTAGGAGTAGGAGCAGCATCTCAAGATTTAGCGAGACATGGAGCAATCACAAGCAGTAATACATCAAGTACTAATGCTGATTGTGCCTGGCTGGAAGCACAAGAGGAAGAGGAAGAGGAGGTAGGCTTTCCAGTCAGGCCACAGGTACCTTTGAGACCAATGACTTATAAGGCAGCTGTCGATCTCAGCCACTTTTTAAAAGAAAAGGGGGGACTGGAAGGGTTAATTTACTCCAAGAAAAGACAGGAGATCCTTGATCTGTGGGTCTATCACACACAAGGATTCCTCCCAGATTGGCAGAACTACACACCAGGGCCAGGGATCAGATACCCACTGACCTTTGGATGGTGCTTCAAACTAGTACCAATAGATCCAGCAGAGGTAGAGGAAGCCAATGAAGGAGAGAACAACGTCTTATTACACCCCATCTGCCAGCATGGAATGGATGATGAAGACAGAGAAGTACTGGTCTGGAAGTTTGACAGCCGCCTGGCATTCACACACACAGCAAGAGAGCTGCATCCGGAGTTTTACAAAGACTGTTGACACAGAAGTTGCTGACAGGGACTTTCTGCCTGGGACTTTCCGCTGGGGACTTTCCAGGGAGGTGTGGTGTGGGAGGAGTTGGGGAGTGGCTAACCCTCAGATGCTGCATATAAGCAGCCGCTTCTCGCCTGTACTGGGTCTCTCTTGCTAGACCAGATTTGAGCCTGGGAGCTCTCTGACTAGCAGGGAACCCACTGCTTAAGCCTCAATAAAGCTTGCCTTGAGTGC');


delete from sequenceanalysis.ref_aa_sequences WHERE ref_nt_id =  (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='GHNJ196');
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('813-2309', 813, 'MGARASVLSGGKLDAWEKIRLRPGGKKQYKLKHIVWASRELERFALNPGLLETAEGCQQLLEQLQSTLRTGSEELKSLYNTIATLWCVHQRIDIRDTKEALDKIEEAQNKSKQKTQQAAAATGSSNQVRVSSQNFPIVQNAQGQMIHQSMSPRTLNAWVKVIEEKGFSPEVIPMFSALSEGAAPQDLNMMLNIVGGHQAAMQMLKDTINEEAAEWDRVHPVHAGPIPPGQMREPRGSDIAGTTSTLQEQIGWMTSNPPIPVGEIYKRWIVLGLNKIVRMYSPVSILDIRQGPKEPFRDYVDRFFKTLRAEQATQDVKNWMTETLLVQNANPDCKTILRALGPGASLEEMMTACQGVGGPSHKARVLAEAMSQAQQSNVMMQRGNFRGQRTIKCFNCGKEGHLARNCKAPRKRGCWKCGKEGHQMKDCTERQANFLGKIWPSNKGRPGNFPQSRPEPSAPPAESLGMGEEVASTPKQEPGDKGIYPPLTSLKSLFGNDP*', 'Gag', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='GHNJ196'));
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('2111-5125', 2111, 'FFRENLAFQQGEARKFSSEQTGTISPTSRELGDGGRGSLNPEAGAGGQGNISSLNFPQITLWQRPLVTVRIGCQLIEALLDTGADDTVLEEKVELPGKWKPKMIGGIGGFIKVRQYDQILIEICGKRAIGTVLVGPTPVNIIGRNMLTQIGCTLNFPISPIETVPVKLKPGMDGPKVKQWPLTEEKIKALTDICTEMEKEGQISKIGPENPYNTPVFAIKKKDSTKWRKLVDFRELNKRPQDFWEVQLGIPHPAGLKKKKSVTVLDVGDAYFSVPLHEDFRKYTAFTIPSVNNETPGIRYQYNVLPQGWKGSPAIFQASMTKILEPFRTNNPEMVIYQYMDDLYVGSDLEIGQHRAKIEELREHLLKWGFTTPDKKHQKEPPFLWMGYELHPDKWTVQHIELPEKDSWTVNDIQKLVGKLNWASQIYPGIKVRQLCKLLRGAKALTDIVTLTEEAELELAENREILKEPVHGVYYDPAKDLVAEIQKQGQDQWTYQIYQEPFKNLKTGKYAKKRSAHTNDVKQLTEVVQKVATESIIIWGKTPKFRLPIQKETWEAWWMDYWQATWIPEWEFVNTPPLVKLWYQLEKDPIVGAETFYVDGAANRETKLGKAGYVTDRGRQKVVSLTETTNQKTELHAIHLALQDSGSEVNIVTDSQYALGIIQAQPDKSDSEIVNLIIEKLIEKDKVYLSWVPAHKGIGGNEQVDKLVSNGIRRVLFLDGIDKAQEEHERYHSNWRAMANDFNLPPIVAKEIVASCDKCQLKGEAMHGQVDCSPGIWQLDCTHLEGKIILVAVHVASGYIEAEVIPAETGQETAYFILKLAGRWPVRVIHTDNGSNFTSAAVKAACWWADVKQEFGIPYNPQSQGVVESMNKELKKIIGQVRDQAEHLKTAVQMAVFIHNFKRKGGIGGYSAGERIIDIIASDIQTKELQKQIIKIQNFRVYYRDSRDPIWKGPAKLLWKGEGAVVIQDNSDIKVVPRRKAKIIKDYGKQMAGDDCVAGRQDED*', 'Pol', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='GHNJ196'));
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('5070-5648', 5070, 'MENRWQVMTVWQVDRMKIRTWNSLVKHHMYVSKKAKDWFYRHHFESRHPKASSEVHIPLGDARLVVRTYWGLNTGERDWHLGHGVSIEWRQRRYSTQIDPDLADQLIHLYYFDCFSESAIRKVLLGQVVRPSCEYQAGHSKVGSLQYLALKALVAPTRRKPPLPSVKKLTEDRWNKPQKTRGHRGNRPINGH*', 'Vif', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='GHNJ196'));
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('5588-5878', 5588, 'MEQAPEDQGPQREPSNQWTLELLEELKQEAVRHFPRPWLHGLGQYIYNTYGDTWEGVEAIIRILQQLLFVHFRIGCQHSRIGIIRGRRGRNGSGRS*', 'Vpr', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='GHNJ196'));
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('5859-6073;8426-8516', 5859, 'MDLVDPNLDPWNHPGSQPTTACSKCYCKICCWHCQLGFLNKGLGISYGRKKRRPRRGTPQNRQDYQNPAPKQPLPTTRGIQADQKESKKKVASKPEPDPCD*', 'Tat', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='GHNJ196'));
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('5998-6073;8426-8700', 5998, 'MAGRSGDPDEELLRTVRIIKILHQSNPYPPPEGSRQTRKNRRRRWRASQSQIRAISERLLSSCLGRPKEPVPLQLPPIERLTLDSGTQQPQEPATGVGSPQISVESSNILGSGTKE*', 'Rev', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='GHNJ196'));
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('6100-6345', 6100, 'MQSLVIAAIVGLVVAFIAAIVVWTIEYIEYRRIRKQKQIDRLLDRIRERAEDSGNESDGDTEELSMLVEVGDYNLLDNADM*', 'Vpu', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='GHNJ196'));
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('6263-8842', 6263, 'MRVMGTQKNYPCLWRWGIIIFWIMLICKGEDLWVTVYYGVPVWRDADTTLFCASDAKSYDTEVHNVWATHACVPTDPSPQEIYLENVTENFNMWKNNMVEQMHEDIISLWDQSLKPCVELTPLCVTLECHSVTNSSENKIGNISIEMQGEIKNCSFNMTTELRDKNRKMHALFYRQDIVPMNESLVSINTTNSTDQYRLINCNTSTVTQACPKVSFEPIPIHYCAPAGFAILKCNDKNFNGTGLCRNVSTVQCTHGIKPVVSTQLLLNGSLAEREVVIRSENFSDNAKTIIVQLAKPVQINCTRPNNNTRTGIHMGLGRTFYATGDIIGDIRQAHCNVSAKAWNDTLQQVATQLGKHYGGNTTIIFTNHSGGDVEIMTHTFNCGGEFFYCNTSRLFNSNWKNGTASSNGTANDIITLQCRIRQIINMWQKVGKAMYAPPIPGVIRCESNITGLLLTRDGGKNTSGVNETFRPEGGNMKDNWRSELYKYKVIKIEPLGVAPTRARRRVVGREKRAIGGLGAALLGFLGAAGSTMGAASITLTVQARQLLSGIVQQQSNLLRAIKAQQELLRLTVWGIKQLQARVLALEGYLRDQQLLGIWGCSGRLICTTNVPWNSTWSNKTYNDIWGNMTWLEWDREISNYTDIIYNLIEVSQNQQEKNEQDLLALDKWASLWSWFSITNWLWYIKIFIMIVGGLIGLRIVFAVLTIINRVRQGYSPLSFQTLTHHQRDPGRPERIEEEGGEQARARSVRLVSGFLALAWDDLRSLCLFSYHRLRDLLLILGHSSLKSLQLGWEALKYLWNLLTYWGQELRNSAISLLDTIAIAVANWTDRVIEIGQRIARAICNIPRRIRQGLERALI*', 'Env', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='GHNJ196'));
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('8844-9530', 8844, 'MGSKLSKSRIVGWARVRERLRRTPPTAERVRRPPPAAEGAGATSQAAVGVGAASQDLARHGAITSSNTSSTNADCAWLEAQEEEEEEVGFPVRPQVPLRPMTYKAAVDLSHFLKEKGGLEGLIYSKKRQEILDLWVYHTQGFLPDWQNYTPGPGIRYPLTFGWCFKLVPIDPAEVEEANEGENNVLLHPICQHGMDDEDREVLVWKFDSRLAFTHTARELHPEFYKDC*', 'Nef', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='GHNJ196'));


delete from sequenceanalysis.virus_strains where virus_strain ='NC_001722';
insert into sequenceanalysis.virus_strains (virus_strain,genbank,species) values ('NC_001722', 'NC_001722', 'HIV');

delete from sequenceanalysis.ref_nt_sequences where name ='NC_001722';
insert into sequenceanalysis.ref_nt_sequences (name,category,subset,mol_type,species,genbank,sequence) values
('NC_001722', 'Virus', 'NC_001722', 'RNA', 'HIV', 'NC_001722', 'TGCAAGGGATGTTTTACAGTAGGAGGAGACATAGAATCCTAGACATATACCTAGAAAAAGAGGAAGGGATAATACCAGATTGGCAGAATTATACTCATGGGCCAGGAGTAAGGTACCCAATGTACTTCGGGTGGCTGTGGAAGCTAGTATCAGTAGAACTCTCACAAGAGGCAGAGGAAGATGAGGCCAACTGCTTAGTACACCCAGCACAAACAAGCAGACATGATGATGAGCATGGGGAGACATTAGTGTGGCAGTTTGACTCCATGCTGGCCTATAACTACAAGGCCTTCACTCTGTACCCAGAAGAGTTTGGGCACAAGTCAGGATTGCCAGAGAAAGAATGGAAGGCAAAACTGAAAGCAAGAGGGATACCATATAGTGAATAACAGGAACAACCATACTTGGTCAAGGCAGGAAGTAGCTACTAAGAAACAGCTGAGGCTGCAGGGACTTTCCAGAAGGGGCTGTAACCAAGGGAGGGACATGGGAGGAGCTGGTGGGGAACGCCCTCATACTTACTGTATAAATGTACCCGCTTCTTGCATTGTATTCAGTCGCTCTGCGGAGAGGCTGGCAGATCGAGCCCTGAGAGGTTCTCTCCAGCACTAGCAGGTAGAGCCTGGGTGTTCCCTGCTGGACTCTCACCAGTACTTGGCCGGTACTGGGCAGACGGCTCCACGCTTGCTTGCTTAAAGACCTCTTCAATAAAGCTGCCAGTTAGAAGCAAGTTAAGTGTGTGTTCCCATCTCTCCTAGTCGCCGCCTGGTCATTCGGTGTTCATCTGAGTAACAAGACCCTGGTCTGTTAGGACCCTTCTCGCTTTGGGAATCCAAGGCAGGAAAATCCCTAGCAGGTTGGCGCCCGAACAGGGACTTGAAGAGGACTGAGAAGCCCTGGAACTCGGCTGAGTGAAGGCAGTAAGGGCGGCAGGAACAAACCACGACGGAGTGCTCCTAGAAAGGCGCGGGCCGAGGTACCAAAGGCGGCGTGTGGAGCGGGAGTGAAAGAGGCCTCCGGGTGAAGGTAAGTACCTACACCAAAAACTGTAGCCAGAAAAGGCTTGTTATCCTACCTTTAGACAGGTAGAAGATTGTGGGAGATGGGCGCGAGAAACTCCGTCTTGAGAGGGAAAAAAGCAGACGAATTAGAAAAAGTTAGGTTACGGCCCGGCGGAAAGAAAAAGTACAGGTTAAAACATATTGTGTGGGCAGCGAATGAATTGGATAAATTCGGATTGGCAGAGAGCCTGTTGGAGTCAAAAGAAGGTTGCCAAAAGATTCTCAGAGTTTTAGATCCATTAGTACCAACAGGGTCAGAAAATTTAAAAAGCCTTTTTAATACCGTCTGCGTCATTTGGTGCTTGCACGCAGAAGAGAAAGTGAAAGATACTGAGGAAGCAAAGAAACTAGCACAGAGACATCTAGTGGCAGAAACTGGAACTGCAGAGAAAATGCCAAATACAAGTAGACCAACAGCACCACCTAGTGGGAAAAGAGGAAACTACCCCGTGCAACAAGCGGGTGGCAACTATGTCCATGTGCCACTGAGCCCCCGAACTCTAAATGCATGGGTAAAATTAGTGGAGGAAAAGAAGTTCGGGGCAGAAGTAGTGCCAGGATTTCAGGCACTCTCAGAAGGCTGCACGCCCTATGATATTAATCAAATGCTTAATTGTGTGGGCGATCACCAAGCAGCTATGCAAATAATCAGAGAGATTATTAATGAAGAAGCAGCAGACTGGGATTCGCAGCACCCAATACCAGGCCCCTTACCAGCAGGACAGCTCAGAGACCCAAGAGGGTCTGACATAGCAGGAACAACAAGCACAGTAGATGAACAGATCCAGTGGATGTATAGGCCACAAAATCCCGTACCGGTAGGGAACATCTACAGAAGATGGATCCAAATAGGGCTGCAAAAGTGTGTCAGAAAGTACAACCCAACTAACATCTTAGACATAAAACAGGGACCAAAAGAACCGTTCCAAAGCTATGTAGACAGGTTCTACAAAAGCTTGAGGGCAGAACAAACAGACCCAGCAGTAAAAAATTGGATGACCCAAACGCTGCTAATACAGAATGCCAACCCAGACTGCAAGTTAGTACTAAAAGGACTGGGGATGAATCCCACCCTAGAAGAGATGCTAACCGCCTGCCAGGGGGTAGGCGGACCAGGCCAGAAAGCCAGGCTAATGGCTGAAGCCCTAAAAGAGGCTATGGGACCAAGCCCTATCCCATTTGCAGCAGCCCAACAAAGAAAGGCAATTAGGTATTGGAACTGTGGAAAGGAGGGACACTCGGCAAGACAGTGCCGAGCACCTAGAAGACAGGGCTGCTGGAAGTGTGGCAAGCCAGGACACATCATGGCAAACTGCCCGGAAAGACAGGCAGGTTTTTTAGGGTTGGGCCCACGGGGAAAGAAGCCTCGCAACTTCCCCGTGACCCAAGCCCCTCAGGGGCTGATACCAACAGCACCTCCGGCAGATCCAGCAGCGGAACTGTTGGAGAGATATATGCAGCAAGGGAGAAAGCAGAGGGAGCAGAGGGAGAGACCATACAAAGAGGTGACGGAGGACTTGCTGCACCTCGAGCAGAGAGAGACACCTCACAGAGAGGAGACAGAGGACTTGCTGCACCTCAATTCTCTCTTTGGAAAAGACCAGTAGTCACAGCGTACATCGAGGATCAGCCGGTAGAAGTCTTACTAGACACAGGGGCTGATGACTCAATAGTAGCAGGAATAGAATTAGGGGACAATTACACTCCAAAAATAGTAGGGGGAATAGGGGGATTTATAAACACCAAAGAATACAAAAATGTAGAAATAAAAGTACTAAATAAAAGAGTAAGAGCCACCATAATGACAGGAGATACCCCAATCAACATCTTTGGCAGAAATATTCTGACAGCCTTAGGCATGTCATTAAATTTACCAGTTGCCAAGATAGAGCCAATAAAAGTAACATTGAAGCCAGGGAAAGATGGACCAAGGCTGAAACAATGGCCCCTAACAAAAGAGAAAATAGAAGCACTAAAAGAGATCTGTGAAAAAATGGAAAAAGAGGGCCAGCTAGAAGAGGCACCTCCAACTAATCCTTATAATACCCCCACATTTGCAATTAAGAAAAAGGACAAGAACAAATGGAGGATGCTGATAGATTTTAGAGAACTAAATAAGGTGACTCAAGATTTCACAGAAATTCAGCTAGGAATTCCACACCCGGCAGGACTAGCCAAAAAGAAAAGGATCTCTATATTAGATGTAGGGGATGCCTATTTTTCCATACCACTACATGAAGATTTTAGGCAGTATACTGCATTTACCCTACCAGCAGTAAACAATATGGAACCAGGAAAAAGATATATATATAAAGTCTTGCCACAAGGATGGAAGGGATCACCAGCAATTTTTCAATACACAATGAGGCAAGTCTTAGAACCTTTCAGAAAAGCAAACCCAGATGTCATTCTCATCCAGTACATGGATGATATCTTAATAGCTAGTGACAGGACAGGTTTAGAGCATGACAAAGTGGTCCTGCAGCTAAAAGAACTTCTAAATGGCCTAGGGTTTTCTACTCCAGATGAGAAGTTCCAAAAAGACCCTCCATTTCAATGGATGGGCTGTGAACTATGGCCAACTAAATGGAAGCTGCAGAAACTACAACTGCCCCAGAAAGACATATGGACAGTCAATGACATCCAAAAGCTAGTGGGAGTCTTAAATTGGGCGGCACAAATCTATTCAGGAATAAAAACCAAACACTTATGTAGACTAATTAGAGGAAAAATGACACTCACAGAAGAAGTGCAGTGGACAGAACTAGCAGAAGCAGAGCTAGAAGAAAACAAAATTATCTTGAGCCAGGAACAAGAAGGATATTATTACCAAGAAGAAAAAGAATTAGAGGCAACAATCCAAAAAAGCCAAGGACATCAATGGACATACAAAATACACCAGGAAGAGAAAATCCTAAAAGTAGGAAAGTATGCAAAGATAAAAAATACCCATACCAATGGGGTCAGATTACTAGCACAGGTAGTTCAGAAAATAGGAAAAGAGGCACTAGTCATTTGGGGACGGATACCAAAATTTCACCTGCCAGTGGAGAGAGAGACCTGGGAGCAGTGGTGGGATAACTACTGGCAAGTGACATGGATCCCAGAGTGGGACTTTGTATCTACCCCACCACTGGTCAGGTTAACATTTAACCTAGTAGGAGATCCTATACCAGGCGCAGAGACCTTCTACACAGATGGATCATGCAATAGACAGTCAAAAGAGGGAAAAGCAGGATATGTAACAGATAGAGGAAAAGACAAAGTAAAAGTATTAGAACAAACTACCAATCAGCAGGCAGAATTAGAAGTCTTTCGGATGGCACTGGCAGACTCAGGCCCAAAGGTTAATATCATAGTAGATTCACAGTATGTAATGGGGATAGTAGCAGGCCAGCCAACAGAGTCAGAAAATAGAATAGTGAACCAGATCATAGAAGAAATGATAAAGAAGGAAGCAGTCTATGTTGCATGGGTCCCAGCCCATAAAGGCATAGGAGGAAACCAGGAAGTAGACCATTTAGTAAGTCAAGGCATCAGACAAGTATTATTCCTGGAAAAGATAGAGCCCGCTCAAGAGGAACATGAAAAATATCATAGCATTATAAAAGAACTAACCCATAAATTTGGAATACCCCTTCTAGTAGCAAGACAGATAGTAAACTCATGTGCCCAATGCCAACAGAAAGGAGAAGCCATACATGGGCAAGTAAATGCAGAAATAGGCGTTTGGCAAATGGACTACACACACTTAGAAGGAAAAATCATTATAGTAGCAGTACATGTTGCAAGTGGATTCATAGAAGCAGAAGTCATCCCACAGGAATCAGGAAGGCAGACAGCACTCTTCCTATTAAAACTGGCCAGTAGGTGGCCAATAACGCACTTGCACACAGACAATGGCCCCAACTTCACTTCACAGGAAGTGAAGATGGTGGCATGGTGGGTAGGTATAGAACAATCCTTTGGAGTACCTTACAACCCACAAAGCCAGGGAGTAGTAGAAGCAATGAATCACCACCTAAAGAATCAGATAAGTAGAATTAGAGAACAGGCAAATACAATAGAAACAATAGTACTGATGGCAGTTCATTGCATGAATTTTAAAAGAAGGGGAGGAATAGGGGATATGACCCCAGCAGAAAGACTAATCAACATGATTACCACAGAACAAGAAATACAATTCCTCCAAAGAAAAAATTCAAATTTTAAAAATTTCCAGGTCTATTACAGAGAAGGCAGAGATCAGCTGTGGAAAGGACCTGGTGAACTACTGTGGAAGGGAGAAGGAGCAGTCATAGTCAAGGTAGGGACAGACATAAAAGTAGTACCAAGAAGGAAGGCCAAGATTATCAGGGACTATGGAGGAAGACAGGAACTGGATAGTAGTCCCCACCTGGAGGGTGCCAGGGAGGATGGAGAAATGGCATGCCCTTGTCAAGTACCTGAAATACAGAACAAAAGACCTAGAGGAGGTGCGCTATGTTCCCCACCACAAGGTGGGATGGGCATGGTGGACTTGCAGCAGGGTAATATTCCCACTACAAGGAAAAAGTCATCTAGAAATACAGGCATATTGGAACCTAACACCAGAAAAAGGATGGCTCTCCTCTCATGCAGTAAGATTAACCTGGTATACAGAAAAGTTCTGGACAGATGTTACCCCAGACTGTGCAGACATCCTAATACATAGCACTTATTTCTCTTGCTTTACGGCAGGTGAAGTAAGAAGAGCCATCAGAGGGGAAAAGTTATTGTCCTGCTGCAACTATCCCCAAGCTCATAAAGCACAGGTACCATCACTTCAATACCTAGCCCTAGTAGTAGTACAACAAAATGACAGACCCCAGAGAAAGGGTACCGCCAGGAAACAGTGGAGAAGAGACCATTGGAGAGGCCTTCGAGTGGCTAGAGAGGACCATAGAAGCCTTAAACAGGGAGGCAGTGAACCATCTGCCCCGAGAGCTCATTTTCCAGGTGTGGCAAAGGTCCTGGAGATATTGGCATGATGAACAAGGGATGTCAGCAAGCTACACAAAGTATAGATATTTGTGCCTAATGCAAAAAGCTATATTTACACATTTCAAGAGAGGGTGCACTTGCTGGGGGGAGGACATGGGCCGGGAAGGATTGGAAGACCAAGGACCTCCCCCTCCTCCCCCTCCAGGTCTAGTCTAATGACTGAAGCACCAACAGAGTTTCCCCCAGAAGATGGGACCCCACGGAGGGACTTAGGGAGTGACTGGGTAATAGAAACTCTGAGGGAAATAAAGGAAGAAGCCTTAAGACATTTTGATCCCCGCTTGCTAATTGCTCTTGGCTACTATATCCATAATAGACATGGAGACACCCTTGAAGGCGCCAGAGAGCTCATTAAAACCCTACAACGAGCCCTCTTCGTGCACTTCAGAGCGGGATGTAACCGCTCAAGAATTGGCTAAACAAGGAGAAGAACTCCTTGCCCAGCTGCACCGACCCCTAGAGCCATGCACTAACAAATGCTATTGTAAGCGATGCAGTTTCCATTGCCAGCTGTGTTTCTCGAAAAAGGGGCTCGGAATATCATATGAGCGAAAGGGCAGACGAAGAAGGACTCCAAGGAAAACTAAGACTCCTTCGCCTTCTGCACCAGACAAGTGAGTATGGAGCCTGGTAGGAATCAGCTGTTTGTTGTCATTTTACTAACAAGTGCTTGCTTAGTATATTGTAGCCAGTATGTGACTGTTTTCTATGGCATACCCGCGTGGAAAAATGCATCTATTCCCTTATTTTGTGCAACTAAAAATAGAGACACTTGGGGGACCATACAGTGCTTGCCAGACAATGATGATTATCAGGAAATAATTTTAAATGTGACAGAGGCTTTTGATGCATGGAATAATACAGTGACAGAACAAGCAGTAGAAGATGTCTGGCATCTATTTGAGACATCAATAAAACCATGTGTCAAGCTAACACCTCTATGTGTGGCAATGAATTGTAGCAGGGTTCAAGGGAATACCACGACCCCGAATCCCAGGACCTCGAGTTCCACAACCTCGAGACCACCCACATCCGCAGCCTCCATAATAAATGAAACTTCTAACTGCATAGAAAACAACACATGCGCAGGATTAGGGTATGAGGAGATGATGCAATGTGAGTTCAATATGAAGGGGTTAGAACAAGATAAGAAAAGGAGGTATAAGGACACATGGTATTTAGAAGATGTGGTTTGTGACAACACAACAGCTGGCACATGTTACATGAGACATTGCAACACATCAATCATCAAAGAGTCATGTGATAAGCACTATTGGGATGCTATGAGGTTTAGATACTGTGCACCACCGGGCTTTGCCCTATTAAGATGTAATGATACCAACTATTCAGGCTTTGAACCTAAGTGCACTAAAGTAGTAGCTGCTTCATGCACAAGGATGATGGAAACGCAAACTTCTACTTGGTTTGGCTTTAATGGCACTAGAGCAGAAAATAGAACATATATCTATTGGCATGGCAGAGATAATAGGACTATCATTAGCTTAAACAAGTATTATAATCTCACAATGCGTTGTAAGAGACCAGGAAATAAGACAGTTTTACCAATAACACTTATGTCAGGATTAGTGTTTCACTCTCAGCCAATCAACACAAGGCCTAGGCAGGCATGGTGCCGGTTTGGAGGCAGATGGAGGGAAGCCATGCAGGAGGTGAAGCAAACCCTTGTACAACATCCCAGATACAAAGGAATCAATGATACAGGGAAAATTAACTTTACGAAACCGGGAGCAGGCTCAGACCCGGAAGTGGCATTTATGTGGACTAACTGCAGAGGAGAATTTCTCTACTGTAACATGACTTGGTTCCTCAATTGGGTAGAAGACAAGAACCAAACACGGCGCAACTATTGCCATATAAAGCAGATAATTAATACCTGGCATAAAGTAGGGAAAAATGTATATTTGCCTCCTAGGGAAGGGGAGTTGGCCTGTGAATCAACAGTAACCAGCATAATTGCTAACATTGACATAGATAAAAATCGGACTCATACCAACATTACCTTTAGTGCAGAAGTGGCAGAACTGTACCGATTAGAACTGGGAGACTACAAATTAATAGAAATAACACCAATTGGCTTCGCACCTACAGATCAGAGAAGGTACTCCTCAACTCCAGTGAGGAACAAAAGAGGTGTGTTCGTGCTAGGGTTCTTGGGTTTTCTCGCGACAGCAGGTTCTGCAATGGGCGCGCGGTCCCTGACGCTGTCAGCCCAGTCCCGGACTTTACTGGCCGGGATAGTGCAGCAACAGCAACAGCTGTTGGACGTAGTCAAGAGACAACAAGAAATGTTGCGACTGACCGTCTGGGGAACGAAAAACCTCCAGGCAAGAGTCACTGCTATCGAGAAGTACCTAAAGCATCAGGCACAGCTAAATTCATGGGGATGTGCGTTTAGACAGGTCTGCCACACTACTGTACCGTGGGTAAATGACTCTTTATCGCCTGACTGGAAAAATATGACATGGCAGGAGTGGGAGAAACAAGTCCGCTACCTAGAGGCAAATATCAGTCAAAGTTTAGAAGAAGCCCAAATTCAACAAGAAAAGAATATGTATGAATTACAAAAATTAAATAGCTGGGATATTCTTGGCAACTGGTTTGACTTAACCTCCTGGGTCAAGTATATTCAATATGGAGTGCATATAGTAGTGGGAATAATAGCTTTAAGAATAGCAATCTATGTAGTGCAATTGTTAAGTAGATTTAGAAAGGGCTATAGGCCTGTTTTCTCTTCCCCCCCCGGTTATCTCCAACAGATCCATATCCACAAGGACCGGGGACAGCCAGCCAACGAAGGAACAGAAGAAGACGTCGGAGGCGACAGTGGTTACGACTTGTGGCCTTGGCCAATAAACTATGTGCAGTTCCTGATCCACCTACTGACTCGCCTCTTGATCGGGCTATACAACATCTGCAGAGACTTACTATCCAAGAACTCCCCGACCCGCCGACTGATCTCCCAGAGTCTAACAGCAATCAGGGACTGGCTGAGACTTAAGGCGGCCCAACTGCAATATGGGTGCGAGTGGATCCAAGAAGCTTTCCAAGCATTCGCGAGGACTACGAGAGAGACTCTTGCGGGCGCGTGGGGATGGTTATGGGAAGCAGCGCGACGCATCGGGAGGGGAATACTCGCAGTTCCAAGAAGAATCAGGCAGGGAGCAGAACTCGCCCTCCTGTGAGGGACAGCAGTATCAGCAGGGAGAGTACATGAACAGCCCATGGAGAAACCCAGCAACAGAAAGACAGAAAGATTTGTATAGGCAGCAAAATATGGATGATGTAGATTCTGATGATGATGACCTAATAGGAGTTCCTGTTACACCAAGAGTACCACGGAGAGAAATGACCTATAAATTGGCAATAGATATGTCACATTTTATAAAAGAAAAAGGGGGACTGCAAGGGATGTTTTACAGTAGGAGGAGACATAGAATCCTAGACATATACCTAGAAAAAGAGGAAGGGATAATACCAGATTGGCAGAATTATACTCATGGGCCAGGAGTAAGGTACCCAATGTACTTCGGGTGGCTGTGGAAGCTAGTATCAGTAGAACTCTCACAAGAGGCAGAGGAAGATGAGGCCAACTGCTTAGTACACCCAGCACAAACAAGCAGACATGATGATGAGCATGGGGAGACATTAGTGTGGCAGTTTGACTCCATGCTGGCCTATAACTACAAGGCCTTCACTCTGTACCCAGAAGAGTTTGGGCACAAGTCAGGATTGCCAGAGAAAGAATGGAAGGCAAAACTGAAAGCAAGAGGGATACCATATAGTGAATAACAGGAACAACCATACTTGGTCAAGGCAGGAAGTAGCTACTAAGAAACAGCTGAGGCTGCAGGGACTTTCCAGAAGGGGCTGTAACCAAGGGAGGGACATGGGAGGAGCTGGTGGGGAACGCCCTCATACTTACTGTATAAATGTACCCGCTTCTTGCATTGTATTCAGTCGCTCTGCGGAGAGGCTGGCAGATCGAGCCCTGAGAGGTTCTCTCCAGCACTAGCAGGTAGAGCCTGGGTGTTCCCTGCTGGACTCTCACCAGTACTTGGCCGGTACTGGGCAGACGGCTCCACGCTTGCTTGCTTAAAGACCTCTTCAATAAAGCTGCCAGTTAGAAGCAAGTTAAGTGTGTGTTCCCATCTCTCCTAGTCGCCGCCTGGTCATTCGGTGTTCATCTGAGTAACAAGACCCTGGTCTGTTAGGACCCTTCTCGCTTTGGGAATCCAAGGCAGGAAAATCCCTAGCA');

delete from sequenceanalysis.ref_aa_sequences where ref_nt_id = (select n.rowid from sequenceanalysis.ref_nt_sequences n where name = 'NC_001722');
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('1103-2398;2398-5754', 1103, 'MGARNSVLRGKKADELEKVRLRPGGKKKYRLKHIVWAANELDKFGLAESLLESKEGCQKILRVLDPLVPTGSENLKSLFNTVCVIWCLHAEEKVKDTEEAKKLAQRHLVAETGTAEKMPNTSRPTAPPSGKRGNYPVQQAGGNYVHVPLSPRTLNAWVKLVEEKKFGAEVVPGFQALSEGCTPYDINQMLNCVGDHQAAMQIIREIINEEAADWDSQHPIPGPLPAGQLRDPRGSDIAGTTSTVDEQIQWMYRPQNPVPVGNIYRRWIQIGLQKCVRKYNPTNILDIKQGPKEPFQSYVDRFYKSLRAEQTDPAVKNWMTQTLLIQNANPDCKLVLKGLGMNPTLEEMLTACQGVGGPGQKARLMAEALKEAMGPSPIPFAAAQQRKAIRYWNCGKEGHSARQCRAPRRQGCWKCGKPGHIMANCPERQAGFFRVGPTGKEASQLPRDPSPSGADTNSTSGRSSSGTVGEIYAAREKAEGAEGETIQRGDGGLAAPRAERDTSQRGDRGLAAPQFSLWKRPVVTAYIEDQPVEVLLDTGADDSIVAGIELGDNYTPKIVGGIGGFINTKEYKNVEIKVLNKRVRATIMTGDTPINIFGRNILTALGMSLNLPVAKIEPIKVTLKPGKDGPRLKQWPLTKEKIEALKEICEKMEKEGQLEEAPPTNPYNTPTFAIKKKDKNKWRMLIDFRELNKVTQDFTEIQLGIPHPAGLAKKKRISILDVGDAYFSIPLHEDFRQYTAFTLPAVNNMEPGKRYIYKVLPQGWKGSPAIFQYTMRQVLEPFRKANPDVILIQYMDDILIASDRTGLEHDKVVLQLKELLNGLGFSTPDEKFQKDPPFQWMGCELWPTKWKLQKLQLPQKDIWTVNDIQKLVGVLNWAAQIYSGIKTKHLCRLIRGKMTLTEEVQWTELAEAELEENKIILSQEQEGYYYQEEKELEATIQKSQGHQWTYKIHQEEKILKVGKYAKIKNTHTNGVRLLAQVVQKIGKEALVIWGRIPKFHLPVERETWEQWWDNYWQVTWIPEWDFVSTPPLVRLTFNLVGDPIPGAETFYTDGSCNRQSKEGKAGYVTDRGKDKVKVLEQTTNQQAELEVFRMALADSGPKVNIIVDSQYVMGIVAGQPTESENRIVNQIIEEMIKKEAVYVAWVPAHKGIGGNQEVDHLVSQGIRQVLFLEKIEPAQEEHEKYHSIIKELTHKFGIPLLVARQIVNSCAQCQQKGEAIHGQVNAEIGVWQMDYTHLEGKIIIVAVHVASGFIEAEVIPQESGRQTALFLLKLASRWPITHLHTDNGPNFTSQEVKMVAWWVGIEQSFGVPYNPQSQGVVEAMNHHLKNQISRIREQANTIETIVLMAVHCMNFKRRGGIGDMTPAERLINMITTEQEIQFLQRKNSNFKNFQVYYREGRDQLWKGPGELLWKGEGAVIVKVGTDIKVVPRRKAKIIRDYGGRQELDSSPHLEGAREDGEMACPCQVPEIQNKRPRGGALCSPPQGGMGMVDLQQGNIPTTRKKSSRNTGILEPNTRKRMALLSCSKINLVYRKVLDRCYPRLCRHPNT*', 'gag-pol fusion polyprotein', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='NC_001722'));
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('1103-2668', 1103, 'MGARNSVLRGKKADELEKVRLRPGGKKKYRLKHIVWAANELDKFGLAESLLESKEGCQKILRVLDPLVPTGSENLKSLFNTVCVIWCLHAEEKVKDTEEAKKLAQRHLVAETGTAEKMPNTSRPTAPPSGKRGNYPVQQAGGNYVHVPLSPRTLNAWVKLVEEKKFGAEVVPGFQALSEGCTPYDINQMLNCVGDHQAAMQIIREIINEEAADWDSQHPIPGPLPAGQLRDPRGSDIAGTTSTVDEQIQWMYRPQNPVPVGNIYRRWIQIGLQKCVRKYNPTNILDIKQGPKEPFQSYVDRFYKSLRAEQTDPAVKNWMTQTLLIQNANPDCKLVLKGLGMNPTLEEMLTACQGVGGPGQKARLMAEALKEAMGPSPIPFAAAQQRKAIRYWNCGKEGHSARQCRAPRRQGCWKCGKPGHIMANCPERQAGFLGLGPRGKKPRNFPVTQAPQGLIPTAPPADPAAELLERYMQQGRKQREQRERPYKEVTEDLLHLEQRETPHREETEDLLHLNSLFGKDQ*', 'gag polyprotein', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='NC_001722'));
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('5423-6070', 5423, 'MEEDRNWIVVPTWRVPGRMEKWHALVKYLKYRTKDLEEVRYVPHHKVGWAWWTCSRVIFPLQGKSHLEIQAYWNLTPEKGWLSSHAVRLTWYTEKFWTDVTPDCADILIHSTYFSCFTAGEVRRAIRGEKLLSCCNYPQAHKAQVPSLQYLALVVVQQNDRPQRKGTARKQWRRDHWRGLRVAREDHRSLKQGGSEPSAPRAHFPGVAKVLEILA*', 'Vif', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='NC_001722'));
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('5898-6239', 5898, 'MTDPRERVPPGNSGEETIGEAFEWLERTIEALNREAVNHLPRELIFQVWQRSWRYWHDEQGMSASYTKYRYLCLMQKAIFTHFKRGCTCWGEDMGREGLEDQGPPPPPPPGLV*', 'Vpx', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='NC_001722'));
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('6239-6502', 6239, 'MTEAPTEFPPEDGTPRRDLGSDWVIETLREIKEEALRHFDPRLLIALGYYIHNRHGDTLEGARELIKTLQRALFVHFRAGCNRSRIG*', 'Vpr', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='NC_001722'));
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('6402-6697;8861-8957', 6402, 'METPLKAPESSLKPYNEPSSCTSERDVTAQELAKQGEELLAQLHRPLEPCTNKCYCKRCSFHCQLCFSKKGLGISYERKGRRRRTPRKTKTPSPSAPDKSISTRTGDSQPTKEQKKTSEATVVTTCGLGQ*', 'Tat', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='NC_001722'));
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('6628-6697;8861-9102', 6628, 'MSERADEEGLQGKLRLLRLLHQTNPYPQGPGTASQRRNRRRRRRRQWLRLVALANKLCAVPDPPTDSPLDRAIQHLQRLTIQELPDPPTDLPESNSNQGLAET*', 'Rev', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='NC_001722'));
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('6704-9286', 6704, 'MEPGRNQLFVVILLTSACLVYCSQYVTVFYGIPAWKNASIPLFCATKNRDTWGTIQCLPDNDDYQEIILNVTEAFDAWNNTVTEQAVEDVWHLFETSIKPCVKLTPLCVAMNCSRVQGNTTTPNPRTSSSTTSRPPTSAASIINETSNCIENNTCAGLGYEEMMQCEFNMKGLEQDKKRRYKDTWYLEDVVCDNTTAGTCYMRHCNTSIIKESCDKHYWDAMRFRYCAPPGFALLRCNDTNYSGFEPKCTKVVAASCTRMMETQTSTWFGFNGTRAENRTYIYWHGRDNRTIISLNKYYNLTMRCKRPGNKTVLPITLMSGLVFHSQPINTRPRQAWCRFGGRWREAMQEVKQTLVQHPRYKGINDTGKINFTKPGAGSDPEVAFMWTNCRGEFLYCNMTWFLNWVEDKNQTRRNYCHIKQIINTWHKVGKNVYLPPREGELACESTVTSIIANIDIDKNRTHTNITFSAEVAELYRLELGDYKLIEITPIGFAPTDQRRYSSTPVRNKRGVFVLGFLGFLATAGSAMGARSLTLSAQSRTLLAGIVQQQQQLLDVVKRQQEMLRLTVWGTKNLQARVTAIEKYLKHQAQLNSWGCAFRQVCHTTVPWVNDSLSPDWKNMTWQEWEKQVRYLEANISQSLEEAQIQQEKNMYELQKLNSWDILGNWFDLTSWVKYIQYGVHIVVGIIALRIAIYVVQLLSRFRKGYRPVFSSPPGYLQQIHIHKDRGQPANEGTEEDVGGDSGYDLWPWPINYVQFLIHLLTRLLIGLYNICRDLLSKNSPTRRLISQSLTAIRDWLRLKAAQLQYGCEWIQEAFQAFARTTRETLAGAWGWLWEAARRIGRGILAVPRRIRQGAELALL*', 'Env', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='NC_001722'));
insert into sequenceanalysis.ref_aa_sequences (exons,start_location,sequence,name,ref_nt_id) VALUES
('9120-9893', 9120, 'MGASGSKKLSKHSRGLRERLLRARGDGYGKQRDASGGEYSQFQEESGREQNSPSCEGQQYQQGEYMNSPWRNPATERQKDLYRQQNMDDVDSDDDDLIGVPVTPRVPRREMTYKLAIDMSHFIKEKGGLQGMFYSRRRHRILDIYLEKEEGIIPDWQNYTHGPGVRYPMYFGWLWKLVSVELSQEAEEDEANCLVHPAQTSRHDDEHGETLVWQFDSMLAYNYKAFTLYPEEFGHKSGLPEKEWKAKLKARGIPYSE*', 'Nef', (SELECT n.rowid FROM sequenceanalysis.ref_nt_sequences n where n.name ='NC_001722'));

