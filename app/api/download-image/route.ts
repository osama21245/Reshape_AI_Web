import { NextResponse } from "next/server";

export async function POST(request: Request) {
    try {
        const { imageUrl } = await request.json();
        
        const response = await fetch(imageUrl);
        const imageBlob = await response.blob();
        
        return new NextResponse(imageBlob, {
            headers: {
                'Content-Type': 'image/png',
                'Content-Disposition': `attachment; filename=ai-room-transformation-${Date.now()}.png`
            }
        });
    } catch (error) {
        console.error('Error downloading image:', error);
        return NextResponse.json({ error: 'Failed to download image' }, { status: 500 });
    }
} 