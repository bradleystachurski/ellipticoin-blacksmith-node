extern crate rocksdb;
use self::rocksdb::DB;
use helpers::*;
use wasmi::*;
use wasmi::RuntimeValue;
use memory_units::Pages;
use std::mem::transmute;
use elipticoin_api::*;

pub struct VM<'a> {
    pub instance: &'a ModuleRef,
    pub db: &'a DB,
}

impl<'a> VM<'a> {
    pub fn new(main: &'a ModuleRef, db: &'a DB) -> VM<'a> {
        VM {
            instance: main,
            db: db,
        }
    }

    pub fn write_pointer(&mut self, vec: Vec<u8>) -> u32 {
        let vec_with_length = vec.to_vec_with_length();
        let vec_pointer = self.call(&"alloc", vec_with_length.len() as u32);
        self.memory().set(vec_pointer, vec_with_length.as_slice()).unwrap();
        vec_pointer
    }

    pub fn read_pointer(&mut self, ptr: u32) -> Vec<u8>{
        let length_slice = self.memory().get(ptr, 4).unwrap();
        let mut length_u8 = [0 as u8; LENGTH_BYTE_COUNT];
        length_u8.clone_from_slice(&length_slice);
        let length: u32 = unsafe {transmute(length_u8)};
        self.memory().get(ptr + 4, length.to_be() as usize).unwrap()
    }

    pub fn call(&mut self, func: &str, arg: u32) -> u32 {
        match self.instance.invoke_export(func, &[RuntimeValue::I32(arg as i32)], self) {
            Ok(Some(RuntimeValue::I32(value))) => value as u32,
            Ok(Some(_)) => 0,
            Ok(None) => 0,
            Err(_e) => 0,
        }
    }

    pub fn memory(&self) -> MemoryRef {
        match self.instance.export_by_name("memory").unwrap() {
            ExternVal::Memory(x) => x,
            _ => MemoryInstance::alloc(Pages(256), None).unwrap(),
        }
    }
}

impl<'a> Externals for VM<'a> {
    fn invoke_index(
        &mut self,
        index: usize,
        args: RuntimeArgs,
        ) -> Result<Option<RuntimeValue>, Trap> {
        ElipticoinAPI::invoke_index(self, index, args)
    }
}
