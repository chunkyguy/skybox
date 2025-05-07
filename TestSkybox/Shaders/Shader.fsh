//
//  Shader.fsh
//  TestSkybox
//
//  Created by Sidharth Juyal on 22/06/12.
//  Copyright (c) 2012 whackylabs. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
