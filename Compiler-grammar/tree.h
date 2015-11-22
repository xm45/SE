#include <stdio.h>
#include <string>
#include <vector>
#include <iostream>
#include <fstream>
#include <sstream>
using namespace std;
class Node{
public:
	string op;
	vector<Node*> *exp;
	Node():op(""),exp(NULL){};
	Node(const Node& other):op(other.op),exp(other.exp){};
	Node(char o):op(""+o),exp(NULL){};
	Node(string o):op(o),exp(NULL){};
	Node(string o, vector<Node*> *e):op(o),exp(e){};
	Node(string o, Node *list, Node *node):op(o){
		if(list != NULL)
			if(list->exp != NULL)
				exp = list->exp;
			else
				exp = new vector<Node*>{list};
		else
			exp = new vector<Node*>();
		exp->push_back(node);
	};
	string pr()
	{
		string ret = "";
		ret += "{";
			ret += "\"op\":";
			ret += "\"";
			ret += op;
			ret += "\"";
		ret += ",";
			ret += "\"exp\":";
			ret += "[";
				if(exp!=NULL)
				{
					int i=0;
					int l=exp->size();
					for(i=0;i<l;i++)
					{
						if(i>0)
							ret += ",";
						ret += (*exp)[i]->pr();
					}
				}
			ret += "]";
		ret += "}";
		return ret;
	};
};