package main

import (
	"bytes"
	"encoding/binary"
	"fmt"
)

func main() {

	fmt.Print("Enter a string(no spaces though): ")

	var str string
	_, err := fmt.Scanln(&str)
	if err != nil {
		fmt.Printf("error lil bro. %v \n", err)
		return
	}

	fmt.Printf("you said: %s\n", str)

	prot, err := prot_msg(str)
	if err != nil {
		fmt.Printf("error lil bro")
		return
	}

	fmt.Printf("%#v\n\n", prot)
}

func prot_msg(msg string) ([]byte, error) {

	var buf bytes.Buffer

	// signature             A     S     M     C     H     A     T
	buf.Write([]byte{0x99, 0x61, 0x73, 0x6D, 0x63, 0x68, 0x61, 0x74})

	buf.WriteByte(0) // major version
	buf.WriteByte(0) // minor version
	// buf.Write([]byte{0x32, 1}) // patch version
	buf.Write(binary.LittleEndian.AppendUint16([]byte{}, 255))

	buf.WriteByte(1) // action type

	buf.Write([]byte{0, 0, 0}) // padding

	buf.WriteString(msg)

	return buf.Bytes(), nil
}
