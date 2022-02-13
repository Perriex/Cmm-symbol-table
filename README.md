# Cmm launguage 
### Part two : Symbol table

With the help of ANTLR 4 tool and Java programming language, information about structs, functions, program scopes and their variables is collected and stored in the symbol table for --C language.

Sample code for this language:

```
struct Person begin
 int age;
 int weight;
 int id;
end
void print_id(list# struct Person person) begin
 int i
 i = 0
 do begin
 display (person[i].id)
 i = i + 1
 end
 while i < n 
end
 
main() begin
 int i, n = 10;
 list #struct Person people;
 while ~ (i == n) begin
 struct Person new_person
 new_person.id = i
 append(people, new_person)
 i = i + 1
 end
 fptr <list #struct Person -> void> pointer = print_id
 pointer(people)
end

```

Other parts:
- [lexical and syntactic analyzer](https://www.google.com)
- [symbol table](https://www.google.com)
- [I'm an inline-style link](https://www.google.com)
- [I'm an inline-style link](https://www.google.com)
