# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

data ADAuditPath
{
    ConvertFrom-StringData -StringData @'
        domain = {Domain}
        Domain Controller OU = OU=Domain Controllers,{Domain}
        AdminSDHolder = CN=AdminSDHolder,CN=System,{Domain}
        RID Manager$ = CN=RID Manager$,CN=System,{Domain}
        Infrastructure = CN=Infrastructure,{Domain}
'@
}

data fileRightsConstant
{
    ConvertFrom-StringData -StringData @'
        Full Control                        = FullControl
        full access                         = FullControl
        Read                                = Read
        Modify                              = Modify
        Read & execute                      = ReadAndExecute
        Read and execute                    = ReadAndExecute
        Create folders                      = CreateDirectories
        append data                         = AppendData
        Create files                        = CreateFiles
        write data                          = WriteData
        list folder contents                = ListDirectory
        all selected except Full control    = AppendData,ChangePermissions,CreateDirectories,CreateFiles,Delete,DeleteSubdirectoriesAndFiles,ExecuteFile,ListDirectory,Modify,Read,ReadAndExecute,ReadAttributes,ReadData,ReadExtendedAttributes,ReadPermissions,Synchronize,TakeOwnership,Traverse,Write,WriteAttributes,WriteData,WriteExtendedAttributes
'@
}

data registryRightsConstant
{
    ConvertFrom-StringData -StringData @'
        Full Control   = FullControl
        Read           = ReadKey
'@
}

data activeDirectoryRightsConstant
{
    ConvertFrom-StringData -StringData @'
        Full Control                    = FullControl
        full access                     = FullControl
        Write all properties            = WriteallProperties
        All extended rights             = AllExtendedRights
        Change infrastructure master    = ChangeInfrastructureMaster
        Modify Permissions              = ModifyPermissions
        Modify Owner                    = ModifyOwner
        Change RID master               = ChangeRIDMaster
        all create                      = Createallchildobjects
        delete and modify permissions   = Delete,ModifyPermissions
        (blank)                         = blank
'@
}

data inheritanceConstant
{
    ConvertFrom-StringData -StringData @'
        This key and subkeys                    = This Key and Subkeys
        This key only                           = This Key Only
        Subkeys only                            = Subkeys Only
        This folder and subfolders              = This folder and subfolders
        This folder only                        = This folder only
        Subfolders and files only               = Subfolders and files only
        This folder, subfolders and files       = This folder subfolders and files
        This folder, subfolder and files        = This folder subfolders and files
        Subfolders only                         = Subfolders only
'@
}

data eventLogRegularExpression
{
    <#
        The name entry was added to support event log name extraction from the
        different formats found in different Window Server STIGs. For example in
        the 2012 Stig, (Application.evtx) was used, in 2016 “Application.evtx”
        is used, so name now extracts the log name from the extension and the
        preceding word.
    #>
    ConvertFrom-StringData -stringdata @'
        name = \\w+\\.evtx
'@
}
