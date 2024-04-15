//

#ifndef CoreSVG_h
#define CoreSVG_h

struct CGSVGDocument;

typedef struct CGSVGDocument *CGSVGDocumentRef;

int CGSVGDocumentWriteToData(CGSVGDocumentRef, CFDataRef, CFDictionaryRef) __attribute__((weak_import));;
void CGContextDrawSVGDocument(CGContextRef, CGSVGDocumentRef) __attribute__((weak_import));;
CGSize CGSVGDocumentGetCanvasSize(CGSVGDocumentRef) __attribute__((weak_import));;
#endif /* CoreSVG_h */
