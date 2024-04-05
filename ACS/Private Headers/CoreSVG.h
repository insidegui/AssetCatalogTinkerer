//

#ifndef CoreSVG_h
#define CoreSVG_h

struct CGSVGDocument;

typedef struct CGSVGDocument *CGSVGDocumentRef;

int CGSVGDocumentWriteToURL(CGSVGDocumentRef, CFURLRef, CFDictionaryRef);
int CGSVGDocumentWriteToData(CGSVGDocumentRef, CFDataRef, CFDictionaryRef);
void CGContextDrawSVGDocument(CGContextRef, CGSVGDocumentRef);
CGSize CGSVGDocumentGetCanvasSize(CGSVGDocumentRef);
#endif /* CoreSVG_h */
