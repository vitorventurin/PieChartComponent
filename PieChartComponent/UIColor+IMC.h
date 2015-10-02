//
//  UIColor+Itau.h
//
//  Created by Vitor Venturin on 14/08/15.
//  Copyright (c) 2015 Vitor Venturin. All rights reserved.
//
//  http://github.com/vitorventurin

#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface UIColor (IMC)

+(UIColor*) fundoDeInvestimento;
+(UIColor*) investimentoImobiliario;
+(UIColor*) cdbRendaFixa;
+(UIColor*) previdenciaPrivada;
+(UIColor*) poupanca;
+(UIColor*) superPoupanca;
+(UIColor*) acoes;

@end
